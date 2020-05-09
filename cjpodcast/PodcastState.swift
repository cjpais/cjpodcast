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
    
    enum PodcastPlayingState {
        case stopped
        case paused
        case loading
        case playing
    }

    private var asset: AVAsset!
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var playerItemContext = 0
    
    private var playerController: AVPlayerViewController = AVPlayerViewController()
    private var timeObserverToken: Any = 0
    private var persistenceManager: PersistenceManager

    @Published var playing: PodcastPlayingState = .stopped
    @Published var playingEpisode: Episode? = nil
    @Published var currTime: Double = 0

    @Published var subscribedPodcasts: [Podcast] = [Podcast]() // TODO get_subscribed_podcasts
    @Published var searchedPodcasts: [Podcast] = [Podcast]() // TODO get_subscribed_podcasts

    @Published var podcastLength: Double = 100
    @Published var isLoaded: Bool = false
    
    init(pMgr: PersistenceManager) {
        self.persistenceManager = pMgr
    }

    func togglePlay() {
        switch self.playing {
        case .paused:
            self.playing = .playing
        case .playing:
            self.playing = .paused
            self.persistCurrEpisodeState()
        case .stopped:
            self.playing = .playing
        default:
            self.playing = .stopped
        }
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
            if ( currentPlayer.currentItem!.status == .readyToPlay)
            {
                let perEp = persistenceManager.getEpisodeById(id: self.playingEpisode!.listenNotesId)
                if perEp != nil && perEp!.currentPosSec != nil {
                    self.seek(time: Double(perEp!.currentPosSec!))
                }
                self.player.play()
                self.startTick()
                self.playing = .playing
            }
        }
    }
        

    func seek(time: Double) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
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
                let cc = MPRemoteCommandCenter.shared()
                cc.pauseCommand.isEnabled = true
                cc.playCommand.isEnabled = true
                cc.pauseCommand.addTarget(handler: { event in
                    return .success
                })
                cc.playCommand.addTarget(handler: { event in
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
    func action(play: PodcastPlayingState, episode: Episode) {
        print("episode seek", episode.currPosSec)
        if play == .playing {
            print(episode.currPosSec)
            
            self.playing = .loading
            if episode != self.playingEpisode {
                setupPlayer(episode)
            } else {
                self.playing = .playing
                self.player.play()
                self.startTick()
            }

        } else {
            player.pause()
            self.removeTick()
            
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


