//
//  Player.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

struct PlayerAction<T: Encodable>: Encodable {
    
    var Action: String
    var Position: Int
    var Entity: Entity<T>
    
    init(action: PodcastState.PodcastPlayerState, episode: PodcastEpisode) {
        Entity = getEntity(from: episode as! T)
        Position = Int(episode.currPosSec)
        Action = translateAction(action: action)
    }
}

func translateAction(action: PodcastState.PodcastPlayerState) -> String {
    switch action {
    case .playing:
        return "play"
    case .paused:
        return "pause"
    case .stopped:
        return "stop"
    case .seeking:
        return ""
    default:
        return ""
    }
}
