//
//  NowPlayingView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct NowPlayingStatusView: View {
    
    var episode: Episode?

    var body: some View {
        VStack(spacing: 0){
            
            if episode != nil {
                ProgressStatusBar(currPos: CGFloat(episode!.currPosSec), totalLength: CGFloat(episode!.audio_length_sec))
            }
            
            HStack{
                PodcastImageView(podcast: episode?.podcast, size: 70, cornerRadiusScale: 0.0)
                
                VStack(alignment: .leading) {
                    Text(episode?.title ?? "No Episode")
                        .font(.footnote)
                        .bold()
                    if self.episode != nil {
                        Text("\(Int(self.episode!.currPosSec/60)):\(Int(self.episode!.currPosSec.truncatingRemainder(dividingBy: 60)))")
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
                PlayButton(episode: episode ?? Episode())
                    .padding(.trailing)
            }
        }
    }
    
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            NowPlayingStatusView(episode: Episode())
        }
    }
}
