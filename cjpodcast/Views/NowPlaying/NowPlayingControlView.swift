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
                    if changed {
                        self.state.changeState(to: .seeking)
                    } else {
                        self.state.changeState(to: self.state.prevPlayerState)
                        self.state.seek(time: self.state.currTime)
                    }
                    self.state.action(play: self.state.playerState, episode: self.state.playingEpisode!)
                }).accentColor(.white)
                
                HStack {
                    Text("\(Int(self.state.currTime/60)):\(Int(self.state.currTime.truncatingRemainder(dividingBy: 60)))")
                        .font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("-\(Int((self.state.playingEpisode!.audio_length_sec - Int(self.state.currTime))/60)):\(Int((Double(self.state.playingEpisode!.audio_length_sec) - self.state.currTime).truncatingRemainder(dividingBy: 60)))")
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
    }
}

struct NowPlayingControlView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingControlView()
            //.environmentObject(PodcastState(Per))
    }
}
