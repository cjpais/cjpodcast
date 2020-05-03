//
//  PodcastEpisodeListItemView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastEpisodeListItemView: View {
    
    @EnvironmentObject var state: PodcastState
    @State var playing: Bool = false
    @State var episode: Episode

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                PodcastImageView(podcast: episode.podcast, size: 75)
                VStack(alignment: .leading) {
                    Text(episode.published_date.getMonthDayYear())
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(episode.title)
                        .font(.headline)
                    Spacer()
                    Text(episode.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                //Spacer()
                //PlayButton(episode: episode)
            }
            Button(action: {
                self.state.togglePlay()
                print(self.state.playing)
                self.state.action(play: self.state.playing, episode: self.episode)
            }) {
                Text("")
            }
        }
    }
}

struct PodcastEpisodeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodeListItemView(episode: Episode())
    }
}
