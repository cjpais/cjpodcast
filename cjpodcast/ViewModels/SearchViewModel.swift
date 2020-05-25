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

let listenNotesSearchString: String = "https://listen-api.listennotes.com/api/v2/search"

final class SearchViewModel: ObservableObject {
    
    enum SearchType: String, CaseIterable, Identifiable {
        case podcasts
        case episodes
        
        var id: SearchType {
            self
        }
        
        var stringPluralUpper: String {
            rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
        
        var stringSingleLower: String {
            String(rawValue.dropLast())
        }
    }

    @Published private(set) var podcasts: [Podcast] = [Podcast]()
    @Published private(set) var podcastImages: [Podcast: UIImage] = [Podcast: UIImage]()
    @Published private(set) var episodes: [SearchEpisode] = [SearchEpisode]()
    @Published private(set) var episodeImages: [SearchEpisode: UIImage] = [SearchEpisode: UIImage]()
    @Published private(set) var error: Bool = false
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    func clear() {
        print("clearing")
        self.episodes = []
        self.episodeImages = [:]
        self.podcasts = []
        self.podcastImages = [:]
    }

    func search(query: String, type: SearchType) {
        guard !query.isEmpty else {
            episodes = []
            podcasts = []
            return
        }
        
        self.error = false
        
        var urlComponents = URLComponents(string: listenNotesSearchString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: type.stringSingleLower),
            URLQueryItem(name: "language", value: "English"),
        ]
        
        print(urlComponents.url!)
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")
        
        switch type {
        case .podcasts:
            searchPodcasts(request: request)
        case .episodes:
            searchEpisodes(request: request)
        }
        
    }
    
    // TODO actually implement this code to search podcasts
    private func searchPodcasts(request: URLRequest) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PodcastSearchResults.self, decoder: decoder)
            .map { $0.results }
            .receive(on: RunLoop.main)
            .catch({ (error) -> Just<[Podcast]> in
                print(error)
                self.error = true
                return Just([])
            })
            .sink(receiveValue: { podcasts in
                for podcast in podcasts {
                    self.fetchPodcastImage(for: podcast)
                }
                //self.podcasts = podcasts
            })
            .store(in: &cancellables)
    }
    

    private func searchEpisodes(request: URLRequest) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: EpisodeSearchResults.self, decoder: decoder)
            .map { $0.results }
            .receive(on: RunLoop.main)
            .catch({ (error) -> Just<[SearchEpisode]> in
                print(error)
                self.error = true
                return Just([])
            })
            .sink(receiveValue: { episodes in
                for episode in episodes {
                    self.fetchEpisodeImage(for: episode)
                }
                self.episodes = episodes
            })
            .store(in: &cancellables)
    }
    
    func fetchPodcastImage(for podcast: Podcast) {
        guard .none == podcastImages[podcast] else {
            return
        }
        
        let request = URLRequest(url: URL(string: podcast.imageURL)!)
        URLSession.shared.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { image in
                var newPodcast = podcast
                newPodcast.image = image!
                self.podcasts.append(newPodcast)
            })
            .store(in: &cancellables)
    }
    
    func fetchEpisodeImage(for episode: SearchEpisode) {
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
    
    /*
     private func getEpisodes(query: String) -> AnyPublisher<[SearchEpisode], Error> {
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
     
     return URLSession.shared.dataTaskPublisher(for: request)
     .map { $0.data }
     .decode(type: EpisodeSearchResults.self, decoder: JSONDecoder())
     .map { $0.results }
     .receive(on: RunLoop.main)
     .eraseToAnyPublisher()
     }
     
     private func getEpisodeImage(from episode: SearchEpisode) -> AnyPublisher<UIImage, URLError> {
     /*
     guard .none == episodeImages[episode] else {
     throw ValidationError
     }*/
     
     let request = URLRequest(url: episode.image!)
     return URLSession.shared.dataTaskPublisher(for: request)
     .map { UIImage(data: $0.data) ?? UIImage() }
     .receive(on: RunLoop.main)
     .eraseToAnyPublisher()
     }
     
     func getEpisodes(query: String) {
     getEpisodes(query: query).flatMap { episodes in
     Publishers.Sequence(sequence: episodes.map { self.getEpisodeImage(from: $0)})
     .collect()
     }
     .sink(receiveCompletion: { _ in },
     receiveValue: { episodes in
     self.episodes = episodes
     })
     }
     */
}
