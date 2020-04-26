//
//  PodcastResults.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

public struct PodcastResults: Decodable {
    
    public var results: [Podcast] = [Podcast]()
    
    private enum CodingKeys: String, CodingKey {
        case results = "results"
    }
}
