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
    var Start: Int
    var End: Int
    var Entity: Entity<T>
    
    init(action: String, episode: PodcastEpisode) {
        Entity = getEntity(from: episode)
        let player: PlayerAction = PlayerAction(Action: <#T##String#>, Start: <#T##Int#>, End: <#T##Int#>, Entity: <#T##Entity<_>#>)
    }
}
