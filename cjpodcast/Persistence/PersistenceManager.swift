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
    
    public func saveEpisodeState(episode: Episode) {
        do {
            let persistentEpisodes: [PersistentEpisode] = try self.moc.fetch(PersistentEpisode.getByEpisodeId(id: episode.listenNotesId))
            if persistentEpisodes.count > 1 || persistentEpisodes.count == 0 {
                fatalError()
            }

            let persistentEpisode = persistentEpisodes[0]
            persistentEpisode.currentPosSec = NSNumber(value: episode.currPosSec)

            try self.moc.save()
        } catch {
            print(error)
        }
    }
    
    public func getNewEpisodes(for subscription: PersistentPodcast) {
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
            .catch({ (error) -> Just<[Episode]> in
                print(error)
                return Just([])
            })
            .receive(on: RunLoop.main)
            .sink(receiveValue: { episodes in
                for episode in episodes {
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
                            print("\(subscription.title!) does not have \(episode.title)")
                            let newEp = PersistentEpisode(context: self.moc)
                            newEp.from(episode: episode)
                            newEp.listenNotesPodcastId = subscription.listenNotesPodcastId!
                            newEp.podcast = subscription
                        } else {
                            print("\(subscription.title!) already has \(episode.title)")
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
    
    public func getNewEpisodes() {
        do {
            let subscriptions = try self.moc.fetch(PersistentPodcast.getAll())
            
            for subscription in subscriptions {
                self.getNewEpisodes(for: subscription)
            }
        } catch {
            print(error)
        }
    }
    
    // TODO make this generic this is pretty horrible to do like this
    public func getEpisodeById(id: String) -> PersistentEpisode? {
        do {
            let episodes = try self.moc.fetch(PersistentEpisode.getByEpisodeId(id: id))
            if episodes.count > 1 || episodes.count == 0 {
                fatalError()
            }
            return episodes[0]
        } catch {
           print(error)
        }
        
        return nil
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

