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
        Group {
            HStack(alignment: .center) {
                Group {
                    VStack(spacing: 7) {
                        PodcastImageView(podcast: episode.podcast, size: 100)
                        HStack {
                            PodcastStateCircle(episode: episode)
                            ProgressStatusBar(currPos: CGFloat(episode.currPosSec), totalLength: CGFloat(episode.audio_length_sec), height: 5)
                                .cornerRadius(3)
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
                    Spacer()
                    Button(action: {
                        if !self.episode.favorite {
                            self.state.addEpisodeToFavorites(episode: self.episode)
                        } else {
                            self.state.removeEpisodeFromFavorites(episode: self.episode)
                        }
                        
                        self.episode.favorite.toggle()

                    }) {
                        Image(systemName: self.episode.favorite ? "heart.fill" : "heart")
                            .foregroundColor(self.episode.favorite ? .red : .white)
                            .font(.system(size: 24))
                    }.buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        self.state.action(play: self.state.togglePlayValue(), episode: self.episode)
                    }) {
                        Text("")
                    }
                }
            }.padding()
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(17)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJCUSTOM")),
                   perform: self.updateEpisodePositionIfPlaying(data:)
        )
    }
    
    func updateEpisodePositionIfPlaying(data: Notification) {
        if self.state.playingEpisode != nil && self.episode.listenNotesId == self.state.playingEpisode!.listenNotesId {
            let player: PodcastPlayer = (data.object as! PodcastPlayer)
            self.episode.currPosSec = Float(player.currTime)
        }
    }
}

struct PodcastEpisodeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodeListItemView(episode: PodcastEpisode())
    }
}
