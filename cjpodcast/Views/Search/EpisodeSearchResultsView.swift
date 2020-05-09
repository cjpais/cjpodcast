//
//  EpisodeSearchView.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/3/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct EpisodeSearchResultsView: View {
    
    var episodes: [SearchEpisode]
    @ObservedObject var model: SearchViewModel

    var body: some View {
        List() {
            ForEach(episodes, id: \.self) { episode in
                HStack {
                    /*
                    self.model.episodeImages[episode].map { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }*/
                    VStack {
                        Text(episode.title_original)
                    }
                }//.onAppear(perform: {self.model.fetchImage(for: episode)})
            }
        }
    }
}

struct EpisodeSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeSearchResultsView(episodes: [SearchEpisode](), model: SearchViewModel())
    }
}
