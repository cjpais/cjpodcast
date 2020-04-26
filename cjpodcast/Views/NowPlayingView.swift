//
//  NowPlayingView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct NowPlayingView: View {
    
    @EnvironmentObject var player: PodcastState
    @State private var binding: CGFloat = 0.0
    
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text("699: Fiasco!")
                        .font(.footnote)
                        .bold()
                    Text("This American Life")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("\(Int(self.player.currTime/60)):\(Int(self.player.currTime.truncatingRemainder(dividingBy: 60)))")
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
                Button(action: {
                    self.player.togglePlay()
                })
                {
                    Image(systemName: (self.player.playing == .playing) ? "pause.fill" : "play.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.trailing)
            }
        }
    }
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingView()
    }
}
