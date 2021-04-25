//
//  Bookmark.swift
//  cjpodcast
//
//  Created by CJ Pais on 7/26/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
public struct Bookmark: Codable, Hashable, Identifiable {
    
    public var id: UUID = UUID()
    var atTime: Int? = nil
    var episode: PodcastEpisode? = nil
    var createdAt: Date? = nil
    var recording: String? = nil
    var note: String? = nil

    init () { }
    
    init (time: Int, e: PodcastEpisode) {
        atTime = time
        episode = e
        createdAt = Date()
    }
    
    init (bookmark: PersistentBookmark, e: PodcastEpisode) {
        guard bookmark.episode != nil else {
            return
        }
        
        id = bookmark.id!
        atTime = Int(truncating: bookmark.atTime!)
        episode = e
        createdAt = bookmark.createdAt
        recording = bookmark.recording
        note = bookmark.note
    }
    
}
