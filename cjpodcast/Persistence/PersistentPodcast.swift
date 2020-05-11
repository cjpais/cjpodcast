//
//  Podcast.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import Combine


public class PersistentPodcast: NSManagedObject, Identifiable {
    @NSManaged public var listenNotesPodcastId: String?
    @NSManaged public var title: String?
    @NSManaged public var publisher: String?
    @NSManaged public var image: Data?
    @NSManaged public var weight: NSNumber?
    @NSManaged public var episodes: NSSet?
    @NSManaged public var subscribed: NSNumber?


    func fromPodcast(podcast: Podcast) {
        listenNotesPodcastId = podcast.listenNotesPodcastId
        title = podcast.title
        publisher = podcast.publisher
        subscribed = podcast.subscribed as NSNumber
        image = podcast.image.pngData()
        
        // TODO context save or something here
        // lightweight layer
    }
    
    func toPodcast() -> Podcast {
        return Podcast(podcast: self)
    }
    
}

extension PersistentPodcast {
    static func getAll() -> NSFetchRequest<PersistentPodcast> {
        let request:NSFetchRequest<PersistentPodcast> = PersistentPodcast.fetchRequest() as! NSFetchRequest<PersistentPodcast>
        let sortDesc = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDesc]
        return request
    }
    
    static func getByTitle(title: String) -> NSFetchRequest<PersistentPodcast> {
        let request:NSFetchRequest<PersistentPodcast> = PersistentPodcast.fetchRequest() as! NSFetchRequest<PersistentPodcast>
        request.predicate = NSPredicate(format: "title = %@", title)
        
        return request
    }
}
