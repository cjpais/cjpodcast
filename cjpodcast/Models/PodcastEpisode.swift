//
//  Episode.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import UIKit

public struct PodcastEpisode: Codable, Hashable {
    
    public var listenNotesId: String = ""
    public var title: String = ""
    public var description: String = ""
    public var published_date: Date = Date()
    public var audio_url: String = ""
    public var audio_length_sec: Int = 0
    public var podcast: Podcast? = nil
    public var currPosSec: Float = 0.0

    private enum CodingKeys: String, CodingKey {
        case listenNotesId = "id"
        case title = "title"
        case description = "description"
        case published_date = "pub_date_ms"
        case audio_url = "audio"
        case audio_length_sec = "audio_length_sec"
    }
    
    init () { }
    
    init(_ episode: PersistentEpisode) {
        listenNotesId = episode.listenNotesEpisodeId ?? ""
        title = episode.title ?? ""
        description = episode.desc ?? ""
        description = description.stripHTML()
        published_date = episode.published ?? Date() // TODO parse the date properly
        audio_url = episode.streamURL ?? ""
        audio_length_sec = episode.audioLengthSec as? Int ?? 0
        currPosSec = episode.currentPosSec as? Float ?? 0
        if episode.podcast != nil {
            podcast = Podcast(podcast: episode.podcast!)
        }
    }
    
    init(episode: SearchEpisode) {
        listenNotesId = episode.id
        title = episode.title_original
        description = episode.description_original.stripHTML()
        published_date = episode.pub_date_ms
        audio_url = episode.audio
        audio_length_sec = episode.audio_length_sec
        currPosSec = 0.0
    }
    
    init(episode: SearchEpisode, image: UIImage) {
        self.init(episode: episode)
        podcast = Podcast(episode: episode, image: image)
    }
    
}