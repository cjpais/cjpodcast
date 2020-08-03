//
//  Bookmark.swift
//  cjpodcast
//
//  Created by CJ Pais on 7/26/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
public struct Bookmark: Codable, Hashable {
    
    var atTime: Int? = nil
    var episode: PodcastEpisode? = nil

    init () { }
    
    init (bookmark: PersistentBookmark, e: PodcastEpisode) {
        guard bookmark.episode != nil else {
            return
        }
        
        atTime = Int(truncating: bookmark.atTime!)
        episode = e
    }

}
