//
//  PersistenceManager.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/1/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData

class PersistenceManager {
    private var moc: NSManagedObjectContext
    
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

