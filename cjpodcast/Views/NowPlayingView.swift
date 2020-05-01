//
//  NowPlayingView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct NowPlayingView: View {
    
    @EnvironmentObject var state: PodcastState
    @State private var binding: CGFloat = 0.0
    
    var body: some View {
        VStack {
            HStack {
                if state.playingEpisode != nil && state.playingEpisode?.podcast != nil {
                    Image(uiImage: (state.playingEpisode?.podcast!.image)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                } else {
                    Rectangle()
                        .frame(width: 60, height: 60)
                }
                VStack(alignment: .leading) {
                    Text(state.playingEpisode?.title ?? "No Episode")
                        .font(.footnote)
                        .bold()
                    Text("\(Int(self.state.currTime/60)):\(Int(self.state.currTime.truncatingRemainder(dividingBy: 60)))")
                        .font(.footnote)
                        .foregroundColor(.gray)
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
            }
        }
    }
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingView()
    }
}
