//
//  PlayButton.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/27/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PlayButton: View {
    @EnvironmentObject var state: PodcastState
    
    var episode: Episode
    var size: CGFloat = 30
    
    @State var spin = false

    var body: some View {
        Button(action: {
            self.state.action(play: self.state.togglePlayValue(), episode: self.episode)
        })
        {
            if self.state.playingEpisode == episode {
                if self.state.playerState == .loading {
                    loadingButton
                } else {
                    playPauseButton
                }
            } else {
                Image(systemName: "play.fill")
                    .font(.system(size: size))
                    .foregroundColor(.white)
            }
        }
    }
    
    var loadingButton: some View {
        Image(systemName: "arrow.2.circlepath")
            .font(.system(size: size))
            .foregroundColor(.white)
            .rotationEffect(.degrees(spin ? 360: 0))
            .animation(loadingAnimation)
            .onAppear() { self.spin.toggle() }
            .onDisappear() { self.spin.toggle() }
    }
    
    var playPauseButton: some View {
        Image(systemName: (self.state.playerState == .playing) ? "pause.fill" : "play.fill")
            .font(.system(size: size))
            .foregroundColor(.white)
    }
    var loadingAnimation: Animation {
        Animation.linear(duration: 0.75)
            .repeatForever(autoreverses: false)
    }

}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(episode: Episode())
    }
}
