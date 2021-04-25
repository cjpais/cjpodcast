//
//  PodcastEpisode.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData

public class PersistentBookmark: NSManagedObject, Identifiable, Encodable {
    @NSManaged public var id: UUID?
    @NSManaged public var atTime: NSNumber?
    @NSManaged public var createdAt: Date?
    @NSManaged public var recording: String?
    @NSManaged public var note: String?

    @NSManaged public var episode: PersistentEpisode?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case atTime = "timestamp"
        case createdAt = "created_at"
        case episode = "episode"
        case note = "note"
        case recording = "recording"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(Int(truncating: atTime ?? 0), forKey: .atTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(episode, forKey: .episode)
        try container.encode(note, forKey: .note)
        try container.encode(recording, forKey: .recording)
    }
}

extension PersistentBookmark {
    static func getAll() -> NSFetchRequest<PersistentBookmark> {
        let request:NSFetchRequest<PersistentBookmark> = NSFetchRequest<PersistentBookmark>(entityName: "PersistentBookmark")
        
        let sortDesc = NSSortDescriptor(key: "atTime", ascending: true)
        
        request.sortDescriptors = [sortDesc]

        return request
    }
    
    static func getById(id: UUID) -> NSFetchRequest<PersistentBookmark> {
        let request:NSFetchRequest<PersistentBookmark> = NSFetchRequest<PersistentBookmark>(entityName: "PersistentBookmark")
        request.predicate = NSPredicate(format: "id = %@", id.uuidString)
        
        return request
    }
}

