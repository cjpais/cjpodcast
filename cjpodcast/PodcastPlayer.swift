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

class PodcastPlayer: ObservableObject {
    
    private var player: AVPlayer = AVPlayer()
    private var playerController: AVPlayerViewController = AVPlayerViewController()
    private var timeObserverToken: Any = 0
    private var cancellable: Cancellable? = nil
    @Published var currTime: Double = 0
    @Published var podcastLength: Double = 100
    @Published var isLoaded: Bool = false
    @Published var podcastSearch: [PodcastResults] = [PodcastResults]()
    
    init() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let context = delegate.persistentContainer.viewContext
            
            /*
            do {
                let subPodcasts = try context.fetch(Podcast.getAll())
                for podcast in subPodcasts {
                    updateEpisodes(podcast: podcast, context: context, cancellable: cancellable)
                    
                    for ep in podcast.episodes! {
                        let blah = ep as! PodcastEpisode
                        print(blah.title)
                    }
                }
            } catch {
                print(error)
            }
            */
            
        } else {
            print("no good")
        }
        /*
        let url = URL(string: "https://www.podtrac.com/pts/redirect.mp3/dovetail.prxu.org/188/7e31e3bc-fdde-4faa-ab55-ba4d7dc54d6f/699.mp3")
        if url != nil {
            player = AVPlayer(url: url!)
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
        }*/
    }
    
    public func updateEpisodes(podcast: Podcast, context: NSManagedObjectContext, cancellable: Cancellable?) {
        print("here")
        if podcast.listenNotesPodcastId != nil {
            if let url = URL(string: String(format: podcastEpisodesFormat, podcast.listenNotesPodcastId!)) {
                print("sending req")
                var req = URLRequest(url: url)
                req.httpMethod = "GET"
                req.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")
    
                self.cancellable = URLSession.shared.dataTaskPublisher(for: req)
                    .map{ $0.data }
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { _ in print("completed") },
                          receiveValue: { data in self.addEpisodes(data: data, context: context, podcast: podcast)})
            } else {
                print("here else")
            }
        }
    }
    
    private func addEpisodes(data: Data, context: NSManagedObjectContext, podcast: Podcast) {
        print("add ep")
        
        let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dict = jsonData as? [String: Any] {
            if let episodes = dict["episodes"] as? [Any] {
                for episode in episodes {
                    if let res = episode as? [String: Any] {
                        let newEp = PodcastEpisode(context: context)
                        for (key, value) in res {
                            switch key {
                            case "id":
                                //print("id", value as! String)
                                newEp.listenNotesEpisodeId = value as? String
                            case "title":
                                //print("title", value as! String)
                                newEp.title = value as? String
                            case "description":
                                //print("desc", value as! String)
                                newEp.desc = value as? String
                            case "pub_date_ms":
                                print("pubdate", value as! NSNumber)
                            case "audio":
                                //print("audio", value as! String)
                                newEp.streamURL = value as? String
                                //newEp.published = value as? String
                                /*
                                 case "image":
                                 newPodcast.image = getImage(imageUrl: value as! String)
                                 */
                            default:
                                continue
                            }
                        }
                        do {
                            newEp.podcast = podcast
                            try context.save()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    func seek(time: Double) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
    
    func removeTick() {
        player.removeTimeObserver(timeObserverToken)
    }
    
    func startTick() {
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: 1), queue: nil, using: periodicCallback(time:))
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
    
    public func searchPodcasts(query: String) {
        if let url = URL(string: String(format: podcastSearchFormat, query.urlEncode())) {
            var searchReq = URLRequest(url: url)
            searchReq.httpMethod = "GET"
            searchReq.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")

            self.cancellable = URLSession.shared.dataTaskPublisher(for: searchReq)
                .map{ $0.data }
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in print("completed") },
                      receiveValue: { data in self.podcastSearch = decodePodcast(data: data)})
        }
    }
    
}


