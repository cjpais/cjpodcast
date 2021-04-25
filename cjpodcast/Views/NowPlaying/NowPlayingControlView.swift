//
//  NowPlayingControlView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI
import AVKit
import Speech

struct NowPlayingControlView: View {
    
    @EnvironmentObject var state: PodcastState
    @State var currTime: CGFloat = 0
    @State var totalTime: CGFloat = 1
    @State var recording: Bool = false
    
    @State private var text: String = ""
    @State private var height: CGFloat = 0

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistentBookmark.getAll()) var bookmarks:FetchedResults<PersistentBookmark>
    
    var bookmarksList: some View {
        List {
            ForEach(state.playingEpisode?.bookmarks ?? []) { bookmark in
                Button(action: {
                    self.state.seek(time: Double(bookmark.atTime!))
                }) {
                    HStack {
                        if bookmark.recording != nil {
                            Image(systemName: "mic.fill")
                        }
                        if bookmark.note != nil {
                            Image(systemName: "pencil")
                            Text(bookmark.note!)
                        }
                        Text(getHHMMSSFromSec(sec: bookmark.atTime!))
                    }
                    
                }
            }
            .onDelete(perform: removeBookmark)
        }
    }
    
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
                    if recording {
                        Text("Recording...")
                        if self.state.transcribedText != nil {
                            Text(self.state.transcribedText!)
                        }
                    } else {
                        Text("Bookmarks").font(.callout).bold()
                        bookmarksList
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

                    ForEach(state.playingEpisode?.bookmarks ?? []) { bookmark in
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
                    RecordAudioButton(size: 40, callback: {
                        self.recording.toggle()
                        
                        if self.recording {
                            // Setup Recording
                            self.state.recordAndTranscribe()
                            
                        } else {
                            self.state.stopRecording()
                        }
                    })
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
            let mark = self.state.playingEpisode?.bookmarks[index]
            
            self.state.playingEpisode?.bookmarks.remove(at: index)
            self.state.removeBookmark(id: mark!.id, bookmark: mark!)
        }
    }
    
}

struct NowPlayingControlView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingControlView()
            //.environmentObject(PodcastState(Per))
    }
}
