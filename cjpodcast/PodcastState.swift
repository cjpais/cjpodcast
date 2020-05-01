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

class PodcastState: ObservableObject {
    
    enum PodcastPlayingState {
        case stopped
        case paused
        case loading
        case playing
    }
    
    private var player: AVPlayer = AVPlayer()
    private var playerController: AVPlayerViewController = AVPlayerViewController()
    private var timeObserverToken: Any = 0

    @Published var playing: PodcastPlayingState = .stopped
    @Published var playingEpisode: Episode? = nil

    @Published var subscribedPodcasts: [Podcast] = [Podcast]() // TODO get_subscribed_podcasts
    @Published var searchedPodcasts: [Podcast] = [Podcast]() // TODO get_subscribed_podcasts

    @Published var currTime: Double = 0
    @Published var podcastLength: Double = 100
    @Published var isLoaded: Bool = false

    func togglePlay() {
        switch self.playing {
        case .paused:
            self.playing = .playing
        case .playing:
            self.playing = .paused
        case .stopped:
            self.playing = .playing
        default:
            self.playing = .stopped
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
            self.currTime = 0.0
            self.playingEpisode = episode
            do {
                UIApplication.shared.beginReceivingRemoteControlEvents()
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                print("playback ok")
                try AVAudioSession.sharedInstance().setActive(true)
                print("session active")
                let cc = MPRemoteCommandCenter.shared()
                cc.pauseCommand.isEnabled = true
                cc.playCommand.isEnabled = true
                cc.pauseCommand.addTarget(handler: { event in
                    self.action(play: false)
                    return .success
                })
                cc.playCommand.addTarget(handler: { event in
                    self.action(play: true)
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
        if play == .playing {
            
            self.playing = .loading
            if episode != self.playingEpisode {
                setupPlayer(episode)
            }
            
            player.play()
            self.startTick()
            self.playing = .playing
        } else {
            player.pause()
            self.removeTick()
            
            if episode != self.playingEpisode {
                setupPlayer(episode)
                player.play()
                self.startTick()
                self.playing = .playing
            }
            
        }
    }
    
    func action(play: Bool) {
        if play {
            player.play()
            self.startTick()
        }
        else {
            player.pause()
            self.removeTick()
        }
    }
    
    func periodicCallback(time: CMTime) {
        self.currTime = Double(time.value / Int64(time.timescale))
        print(time, self.currTime)
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


