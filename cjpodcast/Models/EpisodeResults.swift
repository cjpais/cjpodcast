//
//  EpisodeResults.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

public struct EpisodeResults: Decodable {
    
    public var podcastId: String = ""
    public var episodes: [PodcastEpisode] = [PodcastEpisode]()
    
    private enum CodingKeys: String, CodingKey {
        case podcastId = "id"
        case episodes = "episodes"
    }
}
