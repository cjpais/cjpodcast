//
//  PodcastSearchView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Combine
import SwiftUI


struct SearchView: View {
    
    @ObservedObject var episodesViewModel: EpisodeSearchViewModel = EpisodeSearchViewModel()
    @EnvironmentObject var state: PodcastState
    @State private var searchQuery: String = ""
    @State private var searchType: SearchType = .podcasts
    @FetchRequest(fetchRequest: PersistentPodcast.getAll()) var podcasts:FetchedResults<PersistentPodcast>
    
    var body: some View {
        VStack(alignment: .leading) {
            
            SearchBarView(searchQuery: $searchQuery, searchType: searchType)

            Picker(selection: $searchType, label: Text("Search For")) {
                ForEach(SearchType.allCases) { mode in
                    Text(mode.string)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal])
            
            if state.searchedPodcasts.count > 0 {
                List() {
                    ForEach(state.searchedPodcasts, id: \.self) { podcast in
                        PodcastListItemView(podcast: podcast)
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle("Search")
        .onDisappear(perform: { self.state.searchedPodcasts = [] })
    }
    
    private func cj(_ image: UIImage, userdata: Any?) {
        var pod = userdata as! Podcast
        pod.image = image
        
        self.state.searchedPodcasts.append(pod)

        print("got image for podcast", pod.title)
    }

    func search(query: String) {
        let searchString = String(format: podcastSearchFormat, query.urlEncode())
        guard let url = URL(string: searchString) else {
            print("invalid query: ", searchString)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                if let decodedResponse = try? JSONDecoder().decode(PodcastSearchResults.self, from: data!) {
                    DispatchQueue.main.async {
                        let tmp = decodedResponse.results
                        self.state.searchedPodcasts = []

                        // Set subscribed or not
                        for podcast in tmp {
                            
                            var newPodcast = podcast

                            for subPodcast in self.podcasts {
                                if podcast.listenNotesPodcastId == subPodcast.listenNotesPodcastId {
                                    newPodcast.subscribed = true
                                    break
                                }
                            }
                            
                            downloadImage(from: URL(string: podcast.imageURL)!, userdata: newPodcast, completed: self.cj)
                        }
                    }
                }
            }
            else {
                print("data error")
            }
        }.resume()
    }
    
}

struct PodcastSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
