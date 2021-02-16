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
    @State var backgroundColor: Color = Color(UIColor.systemGray6)
    @State var intLongPress: Bool = false
    
    let colLayout: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
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
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    func button(_ text: String, component: Calendar.Component?, num: Int?) -> some View {
        return Button(action: {
            print("clicked \(text)")
            self.intLongPress = false
            if component != nil && num != nil {
                let date = Calendar.current.date(byAdding: component!, value: num!, to: Date())
                self.state.addToFutureQueue(date: Date().addingTimeInterval(10), episode: self.episode)
                print("adding to queue for \(date)")
            }
            
        }) {
            Text(text)
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    var body: some View {
        
        if intLongPress {
            VStack {
                Text("Re-Listen")
                    .font(.title)
                    .padding(.bottom, 6)

                HStack(spacing: 20) {
                    button("Tomorrow", component: .day, num: 1)
                    button("In a Week", component: .day, num: 7)
                    button("In a Month", component: .month, num: 1)
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 5)
                HStack(spacing: 20) {
                    Spacer()
                    button("In 3 Months", component: .month, num: 3)
                    button("In a Year", component: .year, num: 1)
                    button("Exit", component: nil, num: nil)
                    Spacer()
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(13.0)
        } else {
            Button(action: {
                //self.state.action(play: self.state.togglePlayValue(), episode: self.episode)
                print("clicked")
            }) {
                VStack(spacing: 0) {
                    // Put in group to have common padding
                    Group {
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
                                Text(episode.podcast.title)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }.padding([.horizontal, .top])
        
                        // Bottom Panel
                        HStack {
                            PodcastStateCircle(episode: episode, color: Color(UIColor.systemGray6))
                            Text(getLengthFromSec(sec: episode.audio_length_sec - Int(episode.currPosSec),
                                                  started: episode.currPosSec != 0))
                                .font(.footnote)
                            Spacer()
                            
                            Text("\(episode.bookmarks.count) Bookmarks")
                                .font(.footnote)
                            favoriteButton
                        }.padding()
        
                    }

                    ProgressStatusBar(currPos: CGFloat(episode.currPosSec), totalLength: CGFloat(episode.audio_length_sec), height: 5)
                }
                .background(backgroundColor)
                .cornerRadius(13)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJCUSTOM")),
                           perform: self.updateEpisodePositionIfPlaying(data:))
            }
            .onTapGesture(perform: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.backgroundColor = Color(UIColor.systemGray)
                }
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.backgroundColor = Color(UIColor.systemGray6)
                }
                self.state.action(play: self.state.togglePlayValue(), episode: self.episode)
            })
            .onLongPressGesture(minimumDuration: 0.1, perform: {
                print("press")
                intLongPress = true
            })
        }

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
