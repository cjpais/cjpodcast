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

