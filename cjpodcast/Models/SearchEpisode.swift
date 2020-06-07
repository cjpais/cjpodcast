//
//  SearchEpisode.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/3/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

public struct SearchEpisode: Codable, Hashable {
    
    public var id: String = ""
    public var title_original: String = ""
    public var description_original: String = ""
    public var pub_date_ms: Date = Date()
    public var audio: String = ""
    public var audio_length_sec: Int = 0
    public var image: String = ""
    
    public var podcast_id: String = ""
    public var podcast_title_original: String = ""
    public var publisher_original: String = ""
}
