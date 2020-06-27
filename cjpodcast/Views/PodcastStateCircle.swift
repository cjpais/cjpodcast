//
//  PodcastStateCircle.swift
//  cjpodcast
//
//  Created by CJ Pais on 6/7/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastStateCircle: View {
    
    @EnvironmentObject var state: PodcastState
    @State var episode: PodcastEpisode
    @State var color = Color.black
    
    var animation: Animation {
        Animation.easeInOut(duration: 1.25).repeatForever()
    }
    
    var body: some View {
        ZStack {
            if state.playingEpisode != nil &&
               state.playingEpisode!.listenNotesId == episode.listenNotesId &&
               state.playerState == .playing {
                Circle()
                    .foregroundColor(Color.white)
                    .colorMultiply(self.color)
                    .frame(width: 7, height: 7)
                .onAppear(perform: {
                    withAnimation(self.animation) {
                        self.color = Color.green
                    }
                })
            } else if episode.currPosSec == 0 {
                Circle().foregroundColor(.blue).frame(width: 7, height: 7)
            } else if Int(episode.currPosSec) < episode.audio_length_sec {
                Circle().foregroundColor(.orange).frame(width: 7, height: 7)
            } else {
                Circle().foregroundColor(.green).frame(width: 7, height: 7)
            }
        }
    }
}

struct PodcastStateCircle_Previews: PreviewProvider {
    static var previews: some View {
        PodcastStateCircle(episode: PodcastEpisode())
    }
}
