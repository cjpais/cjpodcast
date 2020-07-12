//
//  PodcastEpisode.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData

public class PersistentBookmark: NSManagedObject, Identifiable {
    @NSManaged public var atTime: NSNumber?

    @NSManaged public var episode: PersistentEpisode?
    
}

extension PersistentBookmark {
    static func getAll() -> NSFetchRequest<PersistentBookmark> {
        let request:NSFetchRequest<PersistentBookmark> = NSFetchRequest<PersistentBookmark>(entityName: "PersistentBookmark")
        
        let sortDesc = NSSortDescriptor(key: "atTime", ascending: true)
        
        request.sortDescriptors = [sortDesc]

        return request
    }
}

