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


public class PersistentPodcast: NSManagedObject, Identifiable, Encodable {
    
    @NSManaged public var id: UUID?
    @NSManaged public var listenNotesPodcastId: String?
    @NSManaged public var title: String?
    @NSManaged public var publisher: String?
    @NSManaged public var image: Data?
    @NSManaged public var weight: NSNumber?
    @NSManaged public var episodes: NSSet?
    @NSManaged public var subscribed: NSNumber?
    @NSManaged public var rssFeed: String?
    
    @NSManaged public var imageURL: String?
    @NSManaged public var desc: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case listenNotesPodcastId = "listen_notes_id"
        case title = "title"
        case publisher = "publisher"
        case subscribed = "subscribed"
        case rssFeed = "rss"
        case image = "image"
        case imageURL = "image_url"
        case desc = "description"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(listenNotesPodcastId, forKey: .listenNotesPodcastId)
        try container.encode(title, forKey: .title)
        try container.encode(publisher, forKey: .publisher)
        try container.encode(Bool(truncating: subscribed ?? false), forKey: .subscribed)
        try container.encode(rssFeed, forKey: .rssFeed)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(desc, forKey: .desc)
        //try container.encode(image, forKey: .image)
    }

    func fromPodcast(podcast: Podcast) {
        id = UUID()
        listenNotesPodcastId = podcast.listenNotesPodcastId
        title = podcast.title
        publisher = podcast.publisher
        subscribed = podcast.subscribed as NSNumber
        rssFeed = podcast.rssFeed
        imageURL = podcast.imageURL
        desc = podcast.description
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
    
    static func getAllSubscribed() -> NSFetchRequest<PersistentPodcast> {
        let request:NSFetchRequest<PersistentPodcast> = PersistentPodcast.fetchRequest() as! NSFetchRequest<PersistentPodcast>
        let sortDesc = NSSortDescriptor(key: "title", ascending: true)
        
        request.predicate = NSPredicate(format: "subscribed == true")
        request.sortDescriptors = [sortDesc]
        
        return request
    }
    
    static func getByTitle(title: String) -> NSFetchRequest<PersistentPodcast> {
        let request:NSFetchRequest<PersistentPodcast> = PersistentPodcast.fetchRequest() as! NSFetchRequest<PersistentPodcast>
        request.predicate = NSPredicate(format: "title = %@", title)
        
        return request
    }
    
    static func getById(id: String) -> NSFetchRequest<PersistentPodcast> {
        let request:NSFetchRequest<PersistentPodcast> = PersistentPodcast.fetchRequest() as! NSFetchRequest<PersistentPodcast>
        request.predicate = NSPredicate(format: "listenNotesPodcastId = %@", id)
        
        return request
    }
}
