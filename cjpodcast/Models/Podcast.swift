//
//  PodcastResults.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import UIKit

public struct Podcast: Codable, Hashable {
    
    public static func == (lhs: Podcast, rhs: Podcast) -> Bool {
        return lhs.listenNotesPodcastId == rhs.listenNotesPodcastId
    }
    
    public var listenNotesPodcastId: String = ""
    public var title: String = ""
    public var publisher: String = ""
    public var subscribed: Bool = false
    public var image: UIImage = UIImage()
    public var imageURL: String = ""
    public var weight: Int = 0

    private enum CodingKeys: String, CodingKey {
        case listenNotesPodcastId = "id"
        case title = "title_original"
        case publisher = "publisher_original"
        case imageURL = "image"
    }
    
    /*
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        publisher = try container.decode(String.self, forKey: .title)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(publisher, forKey: .publisher)
    }
 */
    init() { }

    init(podcast: PersistentPodcast) {
        self.listenNotesPodcastId = podcast.listenNotesPodcastId!
        self.title = podcast.title!
        self.publisher = podcast.publisher ?? "No publisher provided"
        self.subscribed = podcast.subscribed as? Bool ?? true
        
        if podcast.image != nil {
            self.image = UIImage(data: podcast.image!)!
        } else {
            self.image = UIImage()
        }
    }
    
    
    init(episode: SearchEpisode, image: UIImage) {
        listenNotesPodcastId = episode.podcast_id
        title = episode.podcast_title_original
        publisher = episode.publisher_original
        subscribed = false
        self.image = image
        imageURL = episode.image?.absoluteString ?? ""
    }

}
