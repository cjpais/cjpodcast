//
//  UbiqJourney.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import Streamable

let newEntityAPIPath: String = "/new/entity"
let playerActionAPIPath: String = "/action/player"
let startActivityAPIPath: String = "/start/activity"
let stopActivityAPIPath: String = "/stop/activity"
let streamDataPath: String = "/stream"

var streamPath: String {
    let path = UserDefaults().object(forKey: "path") as? Bool ?? true
    let streamPath = (path) ? "/dev" : "/stream"
    
    return streamPath
}

var baseUrl: String {
    return "\(ipAddr)\(streamPath)"
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

func createNewEntityOnServer<T: Encodable>(from: T, uuid: UUID) {
        
    let objectName = "\(type(of: from))"
    let config = StreamConfig(namespace: "cj/podcast", name: objectName, version: "0.0.1", uuid: uuid, location: nil, b64auth: streamAuth)
    let stream = StreamableData(config: config, data: from)
    print("CONFIG: ", config)
    stream.sendStream(to: ipAddr, completionHandler: { e in
        if e != nil {
            fatalError("failed to send stream")
        } else {
            print("completed req")
        }
    })
    
    /*

    let entity: Entity = getEntity(from: from)

    if let url = URL(string: "\(baseUrl)\(newEntityAPIPath)") {
        print("Entity URL", url.absoluteString)
        sendJSONEncodedData(url: url, toEncode: entity)
    } else {
        print("FAILED TO BUILD URL")
    }
    */
}

func sendToStream<T: Encodable>(data: T, name: String, path: String, version: String) {
    var stream = DataStream(path: path, name: name, version: version, data: data)
    if let url = URL(string: "\(baseUrl)\(streamDataPath)") {
        sendJSONEncodedData(url: url, toEncode: stream)
    } else {
        print("FAILED TO BUILD URL")
    }
}

func sendJSONEncodedData<T: Encodable>(url: URL, toEncode: T) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(toEncode)
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
