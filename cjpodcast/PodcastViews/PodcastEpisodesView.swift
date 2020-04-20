//
//  PodcastEpisodesView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastEpisodesView: View {
    
    var podcast: Podcast = Podcast()
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var episodes: [PodcastEpisode] = [PodcastEpisode]()

    var body: some View {
        List() {
            ForEach(episodes) { episode in
                PodcastEpisodeListItemView()
            }
        }
        .navigationBarTitle(podcast.title!)
    }
}

struct PodcastEpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodesView()
    }
}
