//
//  FutureQueue.swift
//  cjpodcast
//
//  Created by CJ Pais on 2/15/21.
//  Copyright © 2021 CJ Pais. All rights reserved.
//

import Foundation

public struct FutureQueueItem: Codable, Hashable {

    var id: UUID? = nil
    var episode: PodcastEpisode? = nil
    var date: Date? = nil
    
    init (item: PersistentFutureQueue) {
        guard item.episode != nil else {
            return
        }
        
        id = item.id!
        episode = PodcastEpisode(item.episode!)
        date = item.date
    }
    
}
