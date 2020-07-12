//
//  PersistenceManager.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/1/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData
import Combine

let podcastURL: String = "https://listen-api.listennotes.com/api/v2/podcasts"

class PersistenceManager {
    
    private var moc: NSManagedObjectContext
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.moc = context
    }
    
    public func save() {
        do {
            try self.moc.save()
        } catch {
            print(error)
        }
    }
    
    public func getEpisodeQueue() -> [PodcastEpisode] {
        var episodes = [PodcastEpisode]()
        
        do {
            let pe = try self.moc.fetch(PersistentEpisode.getQueue())
            for e in pe {
                episodes.append(PodcastEpisode(e))
            }
        } catch {
            print(error)
        }
        
        return episodes
    }
    
    public func persistQueue(queue: [PodcastEpisode]) {
        do {
            let allEps = try self.moc.fetch(PersistentEpisode.getAll())
            for ep in allEps {
                ep.queuePos = 0
            }
            
            for (index, qEp) in queue.enumerated() {
                for ep in allEps {
                    if ep.listenNotesEpisodeId! == qEp.listenNotesId {
                        ep.queuePos = NSNumber(value: index+1)
                        break
                    }
                }
            }
            
            try self.moc.save()
        } catch {
            print(error)
        }
    }
    
    public func addPodcast(podcast: Podcast) -> PersistentPodcast {
        do {
            let persistentPodcasts: [PersistentPodcast] = try self.moc.fetch(PersistentPodcast.getById(id: podcast.listenNotesPodcastId))
            guard persistentPodcasts.count == 0 else {
                if persistentPodcasts.count > 1 {
                    fatalError("Trying to add duplicate podcast to DB")
                }
                print("got existing podcast")
                return persistentPodcasts[0]
            }
            
            print("adding new podcast")
            let newPod = PersistentPodcast(context: self.moc)
            newPod.fromPodcast(podcast: podcast)
            createNewEntityOnServer(from: podcast)
            try self.moc.save()
            return newPod
        } catch {
            fatalError("Failed to add podcast to DB")
        }
    }
    
    public func addEpisode(episode: PodcastEpisode) -> PersistentEpisode {
        do {
            let persistentEpisodes: [PersistentEpisode] = try self.moc.fetch(PersistentEpisode.getByEpisodeId(id: episode.listenNotesId))
            guard persistentEpisodes.count == 0 else {
                if persistentEpisodes.count > 1 {
                    fatalError("Trying to add duplicate episode to DB")
                }
                print("got existing episode")
                return persistentEpisodes[0]
            }

            print("adding new episode")
            let newEp = PersistentEpisode(context: self.moc)
            let podcast = self.addPodcast(podcast: episode.podcast!)
            newEp.new(episode: episode, podcast: podcast)
            createNewEntityOnServer(from: episode)
            try self.moc.save()
            return newEp
        } catch {
            fatalError("Failed to add podcast to DB")
        }
    }

    public func saveEpisodeState(episode: PodcastEpisode) {
        do {
            let ep = self.addEpisode(episode: episode)

            ep.currentPosSec = NSNumber(value: episode.currPosSec)
            ep.audioLengthSec = NSNumber(value: episode.audio_length_sec)

            try self.moc.save()
            
            print("saved ep state")
        } catch {
            print(error)
        }
    }
    
    public func getNewEpisodes(for subscription: PersistentPodcast, callback: @escaping (_: PodcastEpisode) -> ()) {
        let episodesString = String(format: podcastEpisodesFormat, subscription.listenNotesPodcastId!)
        print("ep string: \(episodesString)")
        guard let url = URL(string: episodesString) else {
            print("invalid query: ", episodesString)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: EpisodeResults.self, decoder: decoder)
            .map { $0.episodes }
            .catch({ (error) -> Just<[PodcastEpisode]> in
                print(error)
                return Just([])
            })
            .receive(on: RunLoop.main)
            .sink(receiveValue: { episodes in
                for episode in episodes {
                    print("got ep \(episode.title)")
                    if subscription.episodes != nil {
                        let containsEpisode = subscription.episodes!.contains { element in
                            let subEp: PersistentEpisode = element as! PersistentEpisode
                            if episode.listenNotesId == subEp.listenNotesEpisodeId! {
                                return true
                            } else {
                                return false
                            }
                        }
                        if !containsEpisode {
                            print("adding \(episode.title)")
                            let newEp = PersistentEpisode(context: self.moc)
                            newEp.new(episode: episode, podcast: subscription)
                            newEp.listenNotesPodcastId = subscription.listenNotesPodcastId!
                            callback(PodcastEpisode(newEp))
                        }
                    } else {
                        print("episodes are nil")
                    }
                }
                do {
                    try self.moc.save()
                } catch {
                    print(error)
                }
            })
            .store(in: &cancellables)
    }
    
    public func getNewEpisodes(callback: @escaping (_: PodcastEpisode) -> ()) {
        do {
            let subscriptions = try self.moc.fetch(PersistentPodcast.getAll())
            
            for subscription in subscriptions {
                self.getNewEpisodes(for: subscription, callback: callback)
            }
            
            let ud = UserDefaults()
            ud.set(Date(), forKey: "lastUpdated")
        } catch {
            print(error)
        }
    }
    
    // TODO make this generic this is pretty horrible to do like this
    public func getEpisodeById(id: String) -> PersistentEpisode? {
        do {
            let episodes = try self.moc.fetch(PersistentEpisode.getByEpisodeId(id: id))
            if episodes.count > 1 || episodes.count == 0 {
                return nil
            }
            return episodes[0]
        } catch {
           print(error)
        }
        
        return nil
    }
    
    public func addBookmark(episode: PersistentEpisode, atTime: NSNumber) {
        do {
            let newBookmark = PersistentBookmark(context: self.moc)
            newBookmark.atTime = atTime
            newBookmark.episode = episode

            try self.moc.save()
        } catch {
            print(error)
        }
    }
    
    public func clearDB() {
        do {
            let episodes = try self.moc.fetch(PersistentEpisode.getAll())
            let podcasts = try self.moc.fetch(PersistentPodcast.getAll())
        
            for episode in episodes {
                self.moc.delete(episode)
            }
            
            for podcast in podcasts {
                self.moc.delete(podcast)
            }
            
            // Save all the deletions
            try self.moc.save()
            
        } catch {
            print(error)
        }
    }
}

