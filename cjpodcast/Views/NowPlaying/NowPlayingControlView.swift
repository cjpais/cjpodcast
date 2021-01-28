//
//  NowPlayingControlView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct NowPlayingControlView: View {
    
    @EnvironmentObject var state: PodcastState
    @State var currTime: CGFloat = 0
    @State var totalTime: CGFloat = 1
    
    @State private var text: String = ""
    @State private var height: CGFloat = 0

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistentBookmark.getAll()) var bookmarks:FetchedResults<PersistentBookmark>
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    PodcastImageView(podcast: state.playingEpisode?.podcast ?? Podcast(), size: 100)
                    VStack(alignment: .leading) {
                        Text(state.playingEpisode?.published_date.getMonthDayYear() ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(state.playingEpisode?.title ?? "Nothing Playing")
                            .lineLimit(3)
                        Text(state.playingEpisode?.podcast.publisher ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
    
                VStack(alignment: .leading) {
                    Text("Bookmarks").font(.callout).bold()
                    List {
                        ForEach(state.playingEpisode?.bookmarks ?? [], id: \.self) { bookmark in
                            Button(action: {
                                self.state.seek(time: Double(bookmark.atTime!))
                            }) {
                                Text(getHHMMSSFromSec(sec: bookmark.atTime!))
                            }
                        }
                        .onDelete(perform: removeBookmark)
                    }
                }.padding(.top)
    
                Spacer()

                HStack {
                    GoBack30Button()
                    Spacer()
                    PlayButton(episode: self.state.playingEpisode ?? PodcastEpisode(), size: 60)
                    Spacer()
                    GoForward30Button()
                }.padding([.top, .bottom], 23)
    

                ZStack(alignment: .leading) {
                    Slider(value: $currTime, in:0...totalTime, step: 1, onEditingChanged: { changed in
                        if changed {
                            self.state.changeState(to: .seeking)
                        } else {
                            self.state.changeState(to: self.state.prevPlayerState)
                            self.state.seek(time: Double(self.currTime))
                        }
                        self.state.action(play: self.state.playerState, episode: self.state.playingEpisode!)
                    }).accentColor(.white)

                    ForEach(state.playingEpisode?.bookmarks ?? [], id: \.self) { bookmark in
                        let time = CGFloat(bookmark.atTime!)
                        let offset = (time/totalTime) * (geometry.size.width - 35)
                        Rectangle()
                            .frame(width: 2, height: 10, alignment: .leading)
                            .offset(x: offset, y: 1)
                            .foregroundColor(.red)
                    }
                }

                HStack {
                    Text(getHHMMSSFromSec(sec: Int(self.currTime)))
                        .font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("-" + getHHMMSSFromSec(sec: Int(self.totalTime - self.currTime)))
                        .font(.caption).foregroundColor(.gray)
                }

                HStack {
                    SpeedControlButton(speed: self.$state.playbackSpeed, size: 40)
                    Spacer()
                    RecordAudioButton(size: 40)
                    Spacer()
                    CreateBookmarkButton(size: 45)
                }.padding([.top], 23)
    
            }
            .padding(.bottom, 33)
            .padding(.horizontal)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJCUSTOM")), perform: { out in
                let player: PodcastPlayer = (out.object as! PodcastPlayer)
                self.currTime = player.currTime
                self.totalTime = player.totalTime
            })
            .onAppear(perform: {
                self.currTime = self.state.podcastPlayer.currTime
                self.totalTime = self.state.podcastPlayer.totalTime
            })
        }
    }
    
    func removeBookmark(at offsets: IndexSet) {
        for index in offsets {
            self.state.playingEpisode?.bookmarks.remove(at: index)
            self.state.persistCurrEpisodeState()
        }
    }
    
}

struct NowPlayingControlView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingControlView()
            //.environmentObject(PodcastState(Per))
    }
}
