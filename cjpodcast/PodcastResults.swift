//
//  PodcastResults.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import UIKit

public class PodcastResults: Identifiable {
    public var listenNotesPodcastId: String = ""
    public var title: String = ""
    public var publisher: String = ""
    public var image: UIImage = UIImage()
    public var weight: Int = 0
    
    init() { }
    
    init(podcast: Podcast) {
        self.listenNotesPodcastId = podcast.listenNotesPodcastId!
        self.title = podcast.title!
        self.publisher = podcast.publisher ?? ""
        //self.image = UIImage(data: podcast.image!)!
        //self.weight = Int(podcast.weight!)
    }
}

public func decodePodcast(data: Data) -> [PodcastResults] {
    var podResults = [PodcastResults]()
    let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
    if let dict = jsonData as? [String: Any] {
        if let results = dict["results"] as? [Any] {
            for result in results {
                if let res = result as? [String: Any] {
                    let newPodcast = PodcastResults()
                    for (key, value) in res {
                        switch key {
                        case "id":
                            newPodcast.listenNotesPodcastId = value as! String
                        case "title_original":
                            newPodcast.title = value as! String
                        case "publisher_original":
                            let pub = value as! String
                            let trimmedPub = pub.trimmingCharacters(in: .whitespacesAndNewlines)
                            print(pub, trimmedPub)
                            
                            newPodcast.publisher = trimmedPub
                            /*
                        case "image":
                            newPodcast.image = getImage(imageUrl: value as! String)
 */
                        default:
                            continue
                        }
                    }
                    podResults.append(newPodcast)
                }
            }
        }
    }
    
    print(podResults)
    
    return podResults
}

/*
private func getImage(imageUrl: String) -> UIImage {
    var image = UIImage()
    
    if let url = URL(string: imageUrl) {
        var searchReq = URLRequest(url: url)
        searchReq.httpMethod = "GET"
        searchReq.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")
        
        URLSession.shared.dataTaskPublisher(for: searchReq)
            .map{ $0.data }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in print("completed") },
                  receiveValue: { data in self.podcastSearch = decodePodcast(data: data)})
    }
    
    return image
}
*/
