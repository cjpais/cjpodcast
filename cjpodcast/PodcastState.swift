//
//  PodcastPlayer.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer
import Combine
import CoreData

class PodcastState: NSObject, ObservableObject {
    
    enum PodcastPlayerState {
        case stopped
        case paused
        case loading
        case playing
        case seeking
        case exited
    }

    private var asset: AVAsset!
    private var player: AVQueuePlayer!
    private var playerItem: AVPlayerItem!
    private var playerItemContext = 0
    
    private var playerController: AVPlayerViewController = AVPlayerViewController()
    private var timeObserverToken: Any? = nil
    private var persistenceManager: PersistenceManager
    
    private var nowPlayingInfo: [String:Any] = [String:Any]()
    
    private var sharedAVSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var nc: NotificationCenter = NotificationCenter.default
    
    var podcastPlayer: PodcastPlayer = PodcastPlayer()
    
    @Published var playerState: PodcastPlayerState = .stopped
    @Published var prevPlayerState: PodcastPlayerState = .stopped
    @Published var playingEpisode: PodcastEpisode? = nil
    @Published var currTime: Double = 0
    @Published var episodeQueue: [PodcastEpisode] = [PodcastEpisode]()
    
    @Published var path: Bool = UserDefaults().object(forKey: "path") as? Bool ?? false {
        didSet {
            UserDefaults().set(path, forKey: "path")
        }
    }

    init(pMgr: PersistenceManager) {
        self.persistenceManager = pMgr
        super.init()
        
        self.setupNotifications()
        self.setupMediaControl()
        self.populateEpisodeQueue()
    }
    
    func persistQueue() {
        self.persistenceManager.persistQueue(queue: self.episodeQueue)
    }
    
    private func populateEpisodeQueue() {
        print("populating queue")
        self.episodeQueue = self.persistenceManager.getEpisodeQueue()
    }
    
    func isEpisodeInQueue(episode: PodcastEpisode) -> Bool {
        return self.episodeQueue.contains { $0.listenNotesId == episode.listenNotesId }
    }
    
    func getEpisodeIndexInQueue(episode: PodcastEpisode) -> Int? {
        let index = self.episodeQueue.firstIndex(where: { $0.listenNotesId == episode.listenNotesId })
        return index
    }
    
    func addEpisodeToQueue(episode: PodcastEpisode) {
        let index = getEpisodeIndexInQueue(episode: episode)
        
        if index == nil {
            self.episodeQueue.insert(episode, at: 0)
        }
    }
    
    func removeEpisodeFromQueue(episode: PodcastEpisode) {
        if let index = self.episodeQueue.firstIndex(where: { $0.listenNotesId == episode.listenNotesId }) {
            self.episodeQueue.remove(at: index)
        }
    }
    
    func addEpisodeToFavorites(episode: PodcastEpisode) {
        print("add favorite")
        if let idx = getEpisodeIndexInQueue(episode: episode) {
            episodeQueue[idx].favorite = true
        }
        
        let pEp = self.persistenceManager.getEpisodeById(id: episode.listenNotesId)
        pEp!.favorite = true
        self.persistenceManager.save()
    }
    
    func removeEpisodeFromFavorites(episode: PodcastEpisode) {
        print("remove favorite")
        if let idx = getEpisodeIndexInQueue(episode: episode) {
            episodeQueue[idx].favorite = false
        }
        
        let ep = self.persistenceManager.getEpisodeById(id: episode.listenNotesId)
        ep!.favorite = false
        self.persistenceManager.save()
    }
    
    func setupNotifications() {
        self.nc.addObserver(self,
                            selector: #selector(self.handleInterruption),
                            name: AVAudioSession.interruptionNotification,
                            object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        print("type of interrupt", type.rawValue, AVAudioSession.InterruptionType.began.rawValue)
        
        if type == .began {
            self.action(play: .paused, episode: self.playingEpisode!)
        }
    }
    
    func changeState(to state: PodcastPlayerState) {
        if state == self.playerState { return }
        
        print("changing state from: \(self.playerState) to: \(state)")
        
        self.prevPlayerState = self.playerState
        self.playerState = state
        
        if self.playingEpisode != nil {
            sendPlayerActionToServer(action: self.playerState, episode: self.playingEpisode!)
        }
            
        // Handing when we stop playing
        if self.playerState == .exited || self.playerState == .paused {
            self.persistCurrEpisodeState()
        }
    }

    func togglePlayValue() -> PodcastPlayerState {
        print("toggled the play yo")
        switch self.playerState {
        case .paused:
            return .playing
        case .playing:
            self.persistCurrEpisodeState()
            return .paused
        case .stopped:
            return .playing
        case .exited:
            return .playing
        default:
            return .stopped
        }
    }

    func getNewEps() {
        self.persistenceManager.getNewEpisodes(callback: addEpisodeToQueue(episode:))
    }

    func persistCurrEpisodeState() {
        guard playingEpisode != nil else {
            return
        }
        var ep: PodcastEpisode = playingEpisode!
        ep.currPosSec = Float(podcastPlayer.currTime)
        if let index = getEpisodeIndexInQueue(episode: ep) {
            self.episodeQueue[index].currPosSec = Float(podcastPlayer.currTime)
        }
        
        self.persistenceManager.saveEpisodeState(episode: ep)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let currentPlayer = player , let playerObject = object as? AVPlayerItem, playerObject == currentPlayer.currentItem, keyPath == "status"
        {
            print("ready to play, curr state \(self.playerState) prev state \(self.prevPlayerState)")
            if ( currentPlayer.currentItem!.status == .readyToPlay && self.playerState != .paused ) {
                self.changeState(to: .playing)
                let perEp = persistenceManager.getEpisodeById(id: self.playingEpisode!.listenNotesId)
                if perEp != nil && perEp!.currentPosSec != nil {
                    self.seek(time: Double(truncating: perEp!.currentPosSec!))
                }
                self.player.playImmediately(atRate: 1.0)
                print("real duration \(Int(playerItem.duration.seconds))")
                self.playingEpisode!.audio_length_sec = Int(playerItem.duration.seconds)
                self.startTick()
                
                removeEpisodeFromQueue(episode: self.playingEpisode!)
                addEpisodeToQueue(episode: self.playingEpisode!)
            }
        }
    }
        

    func seek(time: Double) {
        print("seeking to \(time) from \(currTime)")
        if prevPlayerState == .playing {
            removeTick()
        }

        currTime = time
        playingEpisode!.currPosSec = Float(time)
        player.seek(to: CMTime(seconds: time, preferredTimescale: 100))
        self.persistCurrEpisodeState()
        
        if prevPlayerState == .playing {
            startTick()
        }
    }
    
    func removeTick() {
        if timeObserverToken != nil { player.removeTimeObserver(timeObserverToken!) }
        timeObserverToken = nil
        print("removing tick")
        self.persistCurrEpisodeState()
    }
    
    func startTick() {
        print("starting tick")
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: 1), queue: DispatchQueue.main, using: podcastPlayer.tickObserver(time:))
    }
    
    func playerCompletionHandler() {
        removeEpisodeFromQueue(episode: self.playingEpisode!)
        action(play: .playing, episode: episodeQueue[0])
    }

    func setupPlayer(_ episode: PodcastEpisode) {
        self.changeState(to: .loading)
        
        self.podcastPlayer.currTime = CGFloat(episode.currPosSec)
        self.podcastPlayer.totalTime = CGFloat(episode.audio_length_sec)
        self.podcastPlayer.notify()

        let url = URL(string: episode.audio_url)
        if url != nil {
            asset = AVAsset(url: url!)
            playerItem = AVPlayerItem(asset: asset)
            if playingEpisode == nil {
                //player = AVPlayer(playerItem: playerItem)
                player = AVQueuePlayer(playerItem: playerItem)
            } else {
                player.replaceCurrentItem(with: playerItem)
            }
            player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
            print(episode.audio_length_sec)
            let test = CMTime(seconds: Double(episode.audio_length_sec), preferredTimescale: 1)
            player.addBoundaryTimeObserver(forTimes: [NSValue(time: test)], queue: .main, using: playerCompletionHandler)
            sharedAVSession = AVAudioSession.sharedInstance()
            self.playingEpisode = episode
            
            let perEp = persistenceManager.getEpisodeById(id: self.playingEpisode!.listenNotesId)
            if perEp != nil {
                self.currTime = (perEp!.currentPosSec ?? 0) as Double
                self.playingEpisode?.currPosSec = (perEp!.currentPosSec ?? 0) as Float
            }
            
            do {
                print("got here atleast")
                UIApplication.shared.beginReceivingRemoteControlEvents()
                
                try self.sharedAVSession.setCategory(.playback, mode: .default, options: [])
                try self.sharedAVSession.setActive(true)

                self.updateNowPlayingInfo(episode: episode)

                self.currTime = Double(episode.currPosSec)
            } catch {
                print(error)
            }
            playerController.player = player
        }
        else {
            print("problem getting url")
            player = AVQueuePlayer()
        }
    }
    
    // TODO remove this it's too generic and is too ugly
    func action(play: PodcastPlayerState, episode: PodcastEpisode) {
        if play == .playing {
            if episode != self.playingEpisode {
                setupPlayer(episode)
            } else {
                self.changeState(to: play)
                self.player.play()
                self.startTick()
            }
        } else {
            self.changeState(to: play)
            if self.prevPlayerState == .playing {
                player.pause()
                self.removeTick()
            }

            if episode != self.playingEpisode {
                setupPlayer(episode)
            }
        }
    }
    
    func back(numSec: Float) {
        self.changeState(to: .seeking)
        
        // TODO FIX ALL THIS CRAP
        self.playingEpisode!.currPosSec -= numSec
        self.currTime -= Double(numSec)
        self.podcastPlayer.currTime -= CGFloat(numSec)
        
        updateNowPlayingInfo(episode: self.playingEpisode!)
        self.seek(time: Double(self.podcastPlayer.currTime))
        self.changeState(to: self.prevPlayerState)
    }
    
    func forward(numSec: Float) {
        self.changeState(to: .seeking)
        
        self.playingEpisode!.currPosSec += numSec
        self.currTime += Double(numSec)
        self.podcastPlayer.currTime += CGFloat(numSec)
        
        updateNowPlayingInfo(episode: self.playingEpisode!)
        self.seek(time: Double(self.podcastPlayer.currTime))
        self.changeState(to: self.prevPlayerState)
    }
    
    private func setupMediaControl() {
        let cc = MPRemoteCommandCenter.shared()
        
        cc.pauseCommand.isEnabled = true
        cc.playCommand.isEnabled = true
        cc.togglePlayPauseCommand.addTarget(handler: { event in
            self.action(play: self.togglePlayValue(), episode: self.playingEpisode!)
            return .success
        })
        cc.changePlaybackPositionCommand.addTarget(handler: { event in
            print(event)
            let e: MPChangePlaybackPositionCommandEvent = event as! MPChangePlaybackPositionCommandEvent
            self.seek(time: e.positionTime)
            return .success
        })
        cc.skipBackwardCommand.preferredIntervals = [30]
        cc.skipBackwardCommand.addTarget(handler: { event in
            self.back(numSec: 30)
            return .success
        })
        cc.skipForwardCommand.preferredIntervals = [30]
        cc.skipForwardCommand.addTarget(handler: { event in
            self.forward(numSec: 30)
            return .success
        })
    }
    
    private func updateNowPlayingInfo(episode: PodcastEpisode) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.podcast!.title
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = episode.currPosSec
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = episode.audio_length_sec
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { size in
            return episode.podcast!.image
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
    }
}


