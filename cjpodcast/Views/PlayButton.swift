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
    
    var body: some View {
        Button(action: {
            self.state.togglePlay()
            print(self.state.playing)
            self.state.action(play: self.state.playing, episode: self.episode)
        })
        {
            if self.state.playingEpisode == episode {
                Image(systemName: (self.state.playing == .playing) ? "pause.fill" : "play.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "play.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing)
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(episode: Episode())
    }
}
