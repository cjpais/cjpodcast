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
    
    

    var body: some View {
        VStack {
            Text(state.playingEpisode?.title ?? "Nothing Playing")
                .font(.largeTitle)

            PodcastImageView(podcast: state.playingEpisode?.podcast ?? Podcast(), size: 200)
            
            Spacer()

            if self.state.podcastLength > 0 && self.state.playingEpisode != nil {
                Slider(value: $currTime, in:0...totalTime, step: 1, onEditingChanged: { changed in
                    if changed {
                        self.state.changeState(to: .seeking)
                    } else {
                        self.state.changeState(to: self.state.prevPlayerState)
                        self.state.seek(time: Double(self.currTime))
                    }
                    self.state.action(play: self.state.playerState, episode: self.state.playingEpisode!)
                }).accentColor(.white)
                
                HStack {
                    Text(getHHMMSSFromSec(sec: Int(self.currTime)))
                        .font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("-" + getHHMMSSFromSec(sec: Int(self.totalTime - self.currTime)))
                        .font(.caption).foregroundColor(.gray)
                }
            }
            
            HStack {
                GoBack30Button()
                Spacer()
                PlayButton(episode: self.state.playingEpisode ?? Episode(), size: 60)
                Spacer()
                GoForward30Button()

            }

        }
        .padding(.bottom, 50)
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

struct NowPlayingControlView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingControlView()
            //.environmentObject(PodcastState(Per))
    }
}
