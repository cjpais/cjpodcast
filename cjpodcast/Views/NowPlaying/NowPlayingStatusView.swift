//
//  NowPlayingView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct NowPlayingStatusView: View {
    
    @EnvironmentObject var state: PodcastState

    var body: some View {
        VStack(spacing: 0){
            if state.playingEpisode != nil {
                ProgressStatusBar(currPos: CGFloat(state.playingEpisode!.currPosSec), totalLength: CGFloat(state.playingEpisode!.audio_length_sec))
            }
            HStack{
                PodcastImageView(podcast: state.playingEpisode?.podcast, size: 70, cornerRadiusScale: 0.0)
                
                VStack(alignment: .leading) {
                    Text(state.playingEpisode?.title ?? "No Episode")
                        .font(.footnote)
                        .bold()
                    if self.state.playingEpisode != nil {
                        Text("\(Int(self.state.playingEpisode!.currPosSec/60)):\(Int(self.state.playingEpisode!.currPosSec.truncatingRemainder(dividingBy: 60)))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Button(action: {
                })
                {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                }.padding(.trailing)
                Button(action: {
                })
                {
                    Image(systemName: "pencil")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }.padding(.trailing)
                PlayButton(episode: state.playingEpisode ?? Episode())
                    .padding(.trailing)
            }
        }
    }
    
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            NowPlayingStatusView()
                //.environmentObject(PodcastState())
        }
    }
}
