//
//  FavoriteEpisodesView.swift
//  cjpodcast
//
//  Created by CJ Pais on 6/7/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct FavoriteEpisodesView: View {
    
    @FetchRequest(fetchRequest: PersistentEpisode.getFavorites()) var episodes:FetchedResults<PersistentEpisode>
    
    var body: some View {
        List {
            ForEach(episodes, id: \.self) { episode in
                HStack {
                    PodcastEpisodeListItemView(episode: PodcastEpisode(episode)).padding(.vertical, 3)
                }
            }
        }
        .navigationBarTitle("Favorites")
    }
}

struct FavoriteEpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteEpisodesView()
    }
}
