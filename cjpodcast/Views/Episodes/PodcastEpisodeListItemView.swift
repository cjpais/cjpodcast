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
    var episode: Episode

    var body: some View {
        HStack {
            HStack(alignment: .center) {
                Rectangle()
                    .frame(width: 75, height: 75)
                VStack(alignment: .leading) {
                    Text(episode.title)
                        .font(.headline)
                    Spacer()
                    Text(episode.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
            }
            Spacer()
            Button(action: {
                self.playing.toggle()
                if self.playing {
                    self.state.playing = .playing
                    self.state.action(play: self.playing, episode: self.episode)
                } else {
                    self.state.playing = .paused
                }
                /*
                self.loaded = self.player.isLoaded
                self.play.toggle()
                self.player.action(play: self.play)
                */
            })
            {
                Image(systemName: self.playing ? "pause.fill" : "play.fill")
                    .font(.largeTitle)
            }.padding()
        }
    }
}

struct PodcastEpisodeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodeListItemView(episode: Episode())
    }
}
