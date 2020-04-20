//
//  Podcast.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import CoreData
import Combine

let podcastSearchFormat: String = "https://listen-api.listennotes.com/api/v2/search?q=%@&type=podcast&language=English"
let podcastEpisodesFormat: String = "https://listen-api.listennotes.com/api/v2/podcasts/%@"


public class Podcast: NSManagedObject, Identifiable {
    @NSManaged public var listenNotesPodcastId: String?
    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var weight: NSNumber?
    @NSManaged public var episodes: NSSet?

}

extension Podcast {
    static func getAll() -> NSFetchRequest<Podcast> {
        let request:NSFetchRequest<Podcast> = Podcast.fetchRequest() as! NSFetchRequest<Podcast>
        let sortDesc = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDesc]
        return request
    }
    
    static func getByTitle(title: String) -> NSFetchRequest<Podcast> {
        let request:NSFetchRequest<Podcast> = Podcast.fetchRequest() as! NSFetchRequest<Podcast>
        request.predicate = NSPredicate(format: "title = %@", title)
        
        return request
    }
}

extension String {
    func urlEncode() -> String {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)!
    }
}
