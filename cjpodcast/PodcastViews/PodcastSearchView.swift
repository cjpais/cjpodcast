//
//  PodcastSearchView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastSearchView: View {
    
    @EnvironmentObject var player: PodcastPlayer
    @State private var searchQuery: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Query:")
                TextField("Search Podcasts", text: $searchQuery, onCommit: {
                    print("on commit")
                    self.player.searchPodcasts(query: self.searchQuery)
                })
            }
            Text("Results")
                .padding(.vertical)
            List() {
                ForEach(self.player.podcastSearch) { podcast in
                    PodcastListItemView(podcast: podcast)
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Search Podcasts")
    }
}

struct PodcastSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastSearchView()
    }
}
