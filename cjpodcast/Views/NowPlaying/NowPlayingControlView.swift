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

    var body: some View {
        VStack {
            Text(state.playingEpisode?.title ?? "Nothing Playing").font(.largeTitle)

            PodcastImageView(podcast: state.playingEpisode?.podcast ?? Podcast(), size: 200)
            
            Spacer()
            
            if self.state.podcastLength > 0 && self.state.playingEpisode != nil {
                Slider(value: self.$state.currTime, in:0...self.state.podcastLength, step: 1, onEditingChanged: { changed in
                    self.state.togglePlay()
                    self.state.action(play: self.state.playing, episode: self.state.playingEpisode!)
                    self.state.seek(time: self.state.currTime)
                })
                Text("\(Int(self.state.currTime/60)):\(Int(self.state.currTime.truncatingRemainder(dividingBy: 60)))")
            }
            HStack {
                Button(action: {
                    self.state.currTime -= 30
                    self.state.seek(time: self.state.currTime)
                })
                {
                    Image(systemName: "gobackward.30").scaleEffect(2.0)
                }.padding()
                
                Spacer()
                PlayButton(episode: self.state.playingEpisode ?? Episode(), size: 60)
                Spacer()

                Button(action: {
                    self.state.currTime += 30
                    self.state.seek(time: self.state.currTime)
                })
                {
                    Image(systemName: "goforward.30").scaleEffect(2.0)
                }.padding()
            }

        }
        .padding(.bottom, 50)
        .padding(.horizontal)
    }
}

struct NowPlayingControlView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingControlView()
            .environmentObject(PodcastState())
    }
}
