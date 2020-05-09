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
                VStack(spacing: 7) {
                    PodcastImageView(podcast: episode.podcast, size: 100)
                    ProgressStatusBar(currPos: CGFloat(episode.currPosSec), totalLength: CGFloat(episode.audio_length_sec), height: 5)
                        .frame(width: 100)
                        .cornerRadius(5)
                }.padding(.trailing, 7)
                

                VStack(alignment: .leading, spacing: 0) {
                    Text(episode.published_date.getMonthDayYear())
                        .font(.caption) .bold()
                        .foregroundColor(.gray)
                    Text(episode.title)
                        .font(.subheadline).bold()
                        .lineLimit(2)
                    Spacer()
                    Text(episode.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    Spacer()
                    HStack {
                        Text(getLengthFromSec(sec: episode.audio_length_sec - Int(episode.currPosSec),
                                              started: episode.currPosSec != 0))
                            .font(.footnote)
                    }
                }
                
                if episode.currPosSec == 0 {
                    Circle().foregroundColor(.blue).frame(width: 10, height: 10)
                } else if Int(episode.currPosSec) < episode.audio_length_sec {
                    Circle().foregroundColor(.orange).frame(width: 10, height: 10)
                } else {
                    Circle().foregroundColor(.green).frame(width: 10, height: 10)
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
