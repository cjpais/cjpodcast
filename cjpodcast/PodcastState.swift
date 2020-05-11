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
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var playerItemContext = 0
    
    private var playerController: AVPlayerViewController = AVPlayerViewController()
    private var timeObserverToken: Any = 0
    private var persistenceManager: PersistenceManager
    
    private var nowPlayingInfo: [String:Any] = [String:Any]()

    @Published var playerState: PodcastPlayerState = .stopped
    @Published var prevPlayerState: PodcastPlayerState = .stopped
    @Published var playingEpisode: Episode? = nil
    @Published var currTime: Double = 0

    @Published var subscribedPodcasts: [Podcast] = [Podcast]() // TODO get_subscribed_podcasts
    @Published var searchedPodcasts: [Podcast] = [Podcast]() // TODO get_subscribed_podcasts

    @Published var podcastLength: Double = 100
    @Published var isLoaded: Bool = false
    
    init(pMgr: PersistenceManager) {
        self.persistenceManager = pMgr
    }
    
    func changeState(to state: PodcastPlayerState) {
        self.prevPlayerState = self.playerState
        self.playerState = state
    }

    func togglePlay() {
        print("toggled the play yo")
        switch self.playerState {
        case .paused:
            self.changeState(to: .playing)
        case .playing:
            self.changeState(to: .paused)
            self.persistCurrEpisodeState()
        case .stopped:
            self.changeState(to: .playing)
        case .exited:
            self.changeState(to: .playing)
        default:
            self.changeState(to: .stopped)
        }
    }

    func loadAllEps() {
        self.persistenceManager.getNewEpisodes()
    }
    
    func persistCurrEpisodeState() {
        guard playingEpisode != nil else {
            return
        }
        self.persistenceManager.saveEpisodeState(episode: playingEpisode!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let currentPlayer = player , let playerObject = object as? AVPlayerItem, playerObject == currentPlayer.currentItem, keyPath == "status"
        {
            if ( currentPlayer.currentItem!.status == .readyToPlay && self.playerState != .exited )
            {
                print("ready to play, curr state \(self.playerState) prev state \(self.prevPlayerState)")
                let perEp = persistenceManager.getEpisodeById(id: self.playingEpisode!.listenNotesId)
                if perEp != nil && perEp!.currentPosSec != nil {
                    self.seek(time: Double(truncating: perEp!.currentPosSec!))
                }
                self.player.play()
                self.startTick()
                self.playerState = .playing
            }
        }
    }
        

    func seek(time: Double) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
    }
    
    func removeTick() {
        print("removing tick")
        player.removeTimeObserver(timeObserverToken)
    }
    
    func startTick() {
        print("starting tick")
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: 1), queue: nil, using: periodicCallback(time:))
    }

    func setupPlayer(_ episode: Episode) {
        print("setup player")
        let url = URL(string: episode.audio_url)
        if url != nil {
            player = AVPlayer(url: url!)
            player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
            player.automaticallyWaitsToMinimizeStalling = false
            self.playingEpisode = episode
            do {
                UIApplication.shared.beginReceivingRemoteControlEvents()
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
                
                nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currTime
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = episode.audio_length_sec
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                let cc = MPRemoteCommandCenter.shared()
                cc.pauseCommand.isEnabled = true
                cc.playCommand.isEnabled = true
                cc.pauseCommand.addTarget(handler: { event in
                    self.changeState(to: .paused)
                    self.action(play: self.playerState, episode: self.playingEpisode!)
                    return .success
                })
                cc.playCommand.addTarget(handler: { event in
                    self.changeState(to: .playing)
                    self.action(play: self.playerState, episode: self.playingEpisode!)
                    return .success
                })
                cc.changePlaybackPositionCommand.addTarget(handler: { event in
                    print(event)
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
            } catch {
                print(error)
            }
            playerController.player = player
        }
        else {
            print("problem getting url")
            player = AVPlayer()
        }
    }
    
    // TODO remove this it's too generic and is too ugly
    func action(play: PodcastPlayerState, episode: Episode) {
        print("episode seek", episode.currPosSec)
        if play == .playing {
            print(episode.currPosSec)
            
            self.playerState = .loading
            if episode != self.playingEpisode {
                setupPlayer(episode)
            } else {
                self.playerState = .playing
                self.player.play()
                self.startTick()
            }

        } else {
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
        self.playingEpisode!.currPosSec -= numSec
        self.seek(time: Double(self.playingEpisode!.currPosSec))
    }
    
    func forward(numSec: Float) {
        self.playingEpisode!.currPosSec += numSec
        self.seek(time: Double(self.playingEpisode!.currPosSec))
    }
    
    func periodicCallback(time: CMTime) {
        self.playingEpisode!.currPosSec = Float(time.value / Int64(time.timescale))
        self.currTime = Double(time.value / Int64(time.timescale))
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currTime
        if player.currentItem != nil {
            podcastLength = player.currentItem!.duration.seconds
            isLoaded = true
        }
    }
    
    private func setupMediaControl() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "CJ POD"]
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget(handler: { event in
            self.player.play()
            return .success
        })
        commandCenter.pauseCommand.addTarget(handler: { event in
            self.player.pause()
            return .success
        })
    }
}


