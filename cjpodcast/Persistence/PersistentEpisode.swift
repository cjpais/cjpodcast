//
//  PodcastEpisode.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData

public class PersistentEpisode: NSManagedObject, Identifiable {
    @NSManaged public var listenNotesPodcastId: String?
    @NSManaged public var listenNotesEpisodeId: String?
    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    
    @NSManaged public var audioLengthSec: NSNumber?
    @NSManaged public var published: Date?
    @NSManaged public var streamURL: String?
    
    @NSManaged public var startedAt: Date?
    @NSManaged public var currentPosSec: NSNumber?
    @NSManaged public var endedAt: Date?
    
    @NSManaged public var podcast: PersistentPodcast?
    
    func from(episode: Episode) {
        listenNotesEpisodeId = episode.listenNotesId
        title = episode.title
        desc = episode.description
        audioLengthSec = episode.audio_length_sec as NSNumber
        published = episode.published_date
        streamURL = episode.audio_url
        startedAt = nil
        currentPosSec = nil
        endedAt = nil
    }
}

extension PersistentEpisode {
    static func getAll() -> NSFetchRequest<PersistentEpisode> {
        let request:NSFetchRequest<PersistentEpisode> = NSFetchRequest<PersistentEpisode>(entityName: "PersistentEpisode")
        let sortDesc = NSSortDescriptor(key: "published", ascending: false)
        request.sortDescriptors = [sortDesc]
        return request
    }
    
    static func getByEpisodeId(id: String) -> NSFetchRequest<PersistentEpisode> {
        let request:NSFetchRequest<PersistentEpisode> = NSFetchRequest<PersistentEpisode>(entityName: "PersistentEpisode")
        request.predicate = NSPredicate(format: "listenNotesEpisodeId = %@", id)
        
        return request
    }
    
    static func getByPodcastId(id: String) -> NSFetchRequest<PersistentEpisode> {
        let request:NSFetchRequest<PersistentEpisode> = NSFetchRequest<PersistentEpisode>(entityName: "PersistentEpisode")
        request.predicate = NSPredicate(format: "listenNotesPodcastId = %@", id)
        
        return request
    }
    
    static func getByTitle(title: String) -> NSFetchRequest<PersistentEpisode> {
        let request:NSFetchRequest<PersistentEpisode> = NSFetchRequest<PersistentEpisode>(entityName: "PersistentEpisode")
        request.predicate = NSPredicate(format: "title = %@", title)
        
        return request
    }
}
