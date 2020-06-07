//
//  UbiqJourney.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

let newEntityAPIPath: String = "/new/entity"
let playerActionAPIPath: String = "/action/player"
let startActivityAPIPath: String = "/start/activity"
let stopActivityAPIPath: String = "/stop/activity"

var streamPath: String {
    let path = UserDefaults().object(forKey: "path") as? Bool ?? true
    let streamPath = (path) ? "/dev" : "/stream"
    
    return streamPath
}

var baseUrl: String {
    return "\(ip_addr)\(streamPath)"
}

func getEntity<T: Encodable>(from: T) -> Entity<T> {
    return Entity(type: "\(type(of: from))", data: from)
}

func sendPlayerActionToServer(action: PodcastState.PodcastPlayerState, episode: PodcastEpisode) {
    if action == .playing || action == .stopped || action == .paused {
        let playerAction = PlayerAction<PodcastEpisode>(action: action, episode: episode)
        
        if let url = URL(string: "\(baseUrl)\(playerActionAPIPath)") {
            print("Entity URL", url.absoluteString)
            sendJSONEncodedData(url: url, toEncode: playerAction)
        } else {
            print("FAILED TO BUILD URL")
        }
    } else {
        print("NO OP FOR OTHER ACTION")
    }
}

func createNewEntityOnServer<T: Encodable>(from: T) {
    let entity: Entity = getEntity(from: from)

    if let url = URL(string: "\(baseUrl)\(newEntityAPIPath)") {
        print("Entity URL", url.absoluteString)
        sendJSONEncodedData(url: url, toEncode: entity)
    } else {
        print("FAILED TO BUILD URL")
    }
}

func sendJSONEncodedData<T: Encodable>(url: URL, toEncode: T) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(toEncode)
        var request = URLRequest(url: url)
        
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error!)
            }
        }
        
        dataTask.resume()
    } catch {
        print(error)
    }
    
    
}
