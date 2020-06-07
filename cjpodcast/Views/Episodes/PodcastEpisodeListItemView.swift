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
    @State var episode: PodcastEpisode

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Group {
                    VStack(spacing: 7) {
                        PodcastImageView(podcast: episode.podcast, size: 100)
                        HStack {
                            if episode.currPosSec == 0 {
                                Circle().foregroundColor(.blue).frame(width: 7, height: 7)
                            } else if Int(episode.currPosSec) < episode.audio_length_sec {
                                Circle().foregroundColor(.orange).frame(width: 7, height: 7)
                            } else {
                                Circle().foregroundColor(.green).frame(width: 7, height: 7)
                            }
                            ProgressStatusBar(currPos: CGFloat(episode.currPosSec), totalLength: CGFloat(episode.audio_length_sec), height: 5)
                                .cornerRadius(5)
                        }
                        .frame(width: 97)
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
                    Button(action: {
                        self.state.action(play: self.state.togglePlayValue(), episode: self.episode)
                    }) {
                        Text("")
                    }
                }
            }
        }
    }
}

struct PodcastEpisodeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodeListItemView(episode: PodcastEpisode())
    }
}
