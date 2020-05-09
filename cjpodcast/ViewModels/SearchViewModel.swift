//
//  EpisodeSearchViewModel.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/3/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import Combine
import UIKit

let podcastSearchFormat: String = "https://listen-api.listennotes.com/api/v2/search?q=%@&type=podcast&language=English"
let listenNotesSearchString: String = "https://listen-api.listennotes.com/api/v2/search"

final class SearchViewModel: ObservableObject {
    
    enum SearchType: String, CaseIterable, Identifiable {
        case podcasts
        case episodes
        
        var id: SearchType {
            self
        }
        
        var string: String {
            rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
    }

    @Published private(set) var podcasts: [Podcast] = [Podcast]()
    @Published private(set) var podcastImages: [Podcast: UIImage] = [Podcast: UIImage]()
    @Published private(set) var episodes: [SearchEpisode] = [SearchEpisode]()
    @Published private(set) var episodeImages: [SearchEpisode: UIImage] = [SearchEpisode: UIImage]()
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    func clear() {
        episodes = []
        episodeImages = [:]
    }

    func search(query: String) {
        guard !query.isEmpty else {
            return episodes = []
        }
        
        var urlComponents = URLComponents(string: listenNotesSearchString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "episode"),
            URLQueryItem(name: "language", value: "English"),
        ]
        
        print(urlComponents.url!)
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: EpisodeSearchResults.self, decoder: JSONDecoder())
            .map { $0.results }
            .catch({ (error) -> Just<[SearchEpisode]> in
                print(error)
                return Just([])
            })
            .receive(on: RunLoop.main)
            .assign(to: \.episodes, on: self)
            .store(in: &cancellables)
    }
    
    func fetchImage(for episode: SearchEpisode) {
        guard .none == episodeImages[episode] else {
            return
        }
        
        let request = URLRequest(url: episode.image!)
        URLSession.shared.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] image in
                self?.episodeImages[episode] = image
            })
            .store(in: &cancellables)
    }
}