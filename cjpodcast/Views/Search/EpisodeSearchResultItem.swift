//
//  EpisodeSearchResultItem.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/24/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct EpisodeSearchResultItem: View {
    
    @EnvironmentObject var state: PodcastState
    
    @ObservedObject var model: SearchViewModel
    var episode: SearchEpisode
    @State private var queued: Bool = false

    var body: some View {
        HStack {
            /*
            Button(action: {
               print("hit")
            }) {
            */
                Image(uiImage: self.model.episodeImages[episode] ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            //}
            VStack(alignment: .leading){
                Text(episode.pub_date_ms.getMonthDayYear() + " - " + episode.podcast_title_original)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                Spacer()
                Text(episode.title_original)
                    .font(.callout)
                    .lineLimit(2)
                Spacer()
            }
            Spacer()
            Button(action: {
                self.queued.toggle()
                let ep = PodcastEpisode(episode: self.episode,
                                    image: self.model.episodeImages[self.episode] ?? UIImage())
                if self.queued == true {
                    self.state.addEpisodeToQueue(episode: ep)
                } else {
                    self.state.removeEpisodeFromQueue(episode: ep)
                }
            }){
                Text(self.queued ? "Queued": "Queue")
            }.buttonStyle(BorderlessButtonStyle())
        }.onAppear(perform: {
            self.queued = self.state.isEpisodeInQueue(episode: PodcastEpisode(episode: self.episode))
        })
    }
}

struct EpisodeSearchResultItem_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeSearchResultItem(model: SearchViewModel(), episode: SearchEpisode())
    }
}
