//
//
//  PodcastEpisodeListItemView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct SpotifyListItem: View {
    
    @EnvironmentObject var state: PodcastState
    @State var playing: Bool = false
    @State var episode: PodcastEpisode
    
    var favoriteButton: some View {
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
                .font(.system(size: 20))
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Put in group to have common padding
                Group {
    
                    // Date
                    /*
                    HStack {
                        Text(episode.published_date.getMonthDayYear())
                            .font(.caption)
                            .bold()
                            .foregroundColor(.gray)
                    }
                    .padding([.top], 7)
                    .padding(.horizontal)
 */

                    // Image + Basic Info
                    HStack() {
                        PodcastImageView(podcast: episode.podcast, size: 75)
                        
                        // Basic Episode Info
                        VStack(alignment: .leading) {
                            Text(episode.published_date.getMonthDayYear())
                                .font(.caption)
                                .bold()
                                .foregroundColor(.gray)
                            Text(episode.title)
                                .font(.subheadline).bold()
                                .lineLimit(2)
                            Text(episode.podcast?.title ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        Spacer()
                    }.padding([.horizontal, .top])
    
                    // Description
                    /*
                    Text(episode.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .padding(.horizontal)
                    */
    
                    // Bottom Panel
                    HStack {
                        PodcastStateCircle(episode: episode, color: Color(UIColor.systemGray6))
                        Text(getLengthFromSec(sec: episode.audio_length_sec - Int(episode.currPosSec),
                                              started: episode.currPosSec != 0))
                            .font(.footnote)
    
                        Spacer()
    
                        favoriteButton
                    }.padding()
    
                }//.padding()

                ProgressStatusBar(currPos: CGFloat(episode.currPosSec), totalLength: CGFloat(episode.audio_length_sec), height: 5)
            }
            Button(action: {
                self.state.action(play: self.state.togglePlayValue(), episode: self.episode)
            }) {
                Text("")
            }
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(13)
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

struct SpotifyListItem_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyListItem(episode: PodcastEpisode())
    }
}
