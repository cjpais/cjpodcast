//
//  PersistentFutureQueue.swift
//  cjpodcast
//
//  Created by CJ Pais on 2/15/21.
//  Copyright © 2021 CJ Pais. All rights reserved.
//

import Foundation
import CoreData

public class PersistentFutureQueue: NSManagedObject, Identifiable, Encodable {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?

    @NSManaged public var episode: PersistentEpisode?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case date = "date"
        case episode = "episode"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(episode, forKey: .episode)
    }
}

extension PersistentFutureQueue {
    static func getAll() -> NSFetchRequest<PersistentFutureQueue> {
        let request:NSFetchRequest<PersistentFutureQueue> = NSFetchRequest<PersistentFutureQueue>(entityName: "PersistentFutureQueue")
        
        let sortDesc = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDesc]

        return request
    }
    
    static func getItem(id: UUID) -> NSFetchRequest<PersistentFutureQueue> {
        let request:NSFetchRequest<PersistentFutureQueue> = NSFetchRequest<PersistentFutureQueue>(entityName: "PersistentFutureQueue")
        request.predicate = NSPredicate(format: "id = %@", id.uuidString)
        
        return request
    }
}
