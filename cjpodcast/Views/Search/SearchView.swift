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
    
    @ObservedObject var searchViewModel: SearchViewModel
    //@EnvironmentObject var state: PodcastState
    @State private var searchType: SearchViewModel.SearchType = .podcasts
    @State private var query: String = ""
    @FetchRequest(fetchRequest: PersistentPodcast.getAll()) var podcasts:FetchedResults<PersistentPodcast>
    
    var navSubButton: some View {
        Button(action: {
            
        }) {
            Text("Subscribe")
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            SearchBarView(model: searchViewModel, searchType: searchType, query: $query) {
                self.searchViewModel.search(query: self.query, type: self.searchType)
            }

            Picker(selection: $searchType, label: Text("Search For")) {
                ForEach(SearchViewModel.SearchType.allCases) { mode in
                    Text(mode.stringPluralUpper)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal])
            
            if searchType == .podcasts {
                PodcastSearchResultsView(podcasts: searchViewModel.podcasts, model: searchViewModel)
                    .navigationBarItems(trailing: EmptyView())
            } else {
                EpisodeSearchResultsView(episodes: searchViewModel.episodes, model: searchViewModel)
                    .navigationBarItems(trailing: navSubButton)
            }

            Spacer()
        }
        .navigationBarTitle("Search")
        .onDisappear(perform: { self.searchViewModel.clear() })
    }
}
    
struct PodcastSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(searchViewModel: SearchViewModel())
    }
}
