//
//  PodcastEpisode.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData


public class PodcastEpisode: NSManagedObject, Identifiable {
    @NSManaged public var listenNotesEpisodeId: String?
    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    
    @NSManaged public var audioLengthSec: NSNumber?
    @NSManaged public var published: Date?
    @NSManaged public var streamURL: String?
    
    @NSManaged public var startedAt: Date?
    @NSManaged public var currentPosSec: NSNumber?
    @NSManaged public var endedAt: Date?
    
    @NSManaged public var podcast: Podcast?
}

/*
extension PodcastEpisode {
    static func getExistingEpisodes(podcast: Podcast) -> [PodcastEpisode] {
        var episodes = [PodcastEpisode]()
        let request:NSFetchRequest<PodcastEpisode> = NSFetchRequest<PodcastEpisode>(entityName: "PodcastEpisode")
        request.predicate = NSPredicate(format: "podcast = %@", podcast)
        
        do {
            episodes = try request.execute()
        } catch {
            print(error)
        }
        
        return episodes
    }
}

private func decodeEpisodes(data: Data, context: NSManagedObjectContext) {
    print("NOT NOTHING FUCK YOU")
}
*/
