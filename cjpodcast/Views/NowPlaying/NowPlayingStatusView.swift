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
    @State var currTime: CGFloat = 0
    @State var totalTime: CGFloat = .greatestFiniteMagnitude

    var body: some View {
        return VStack(spacing: 0) {
            
            if self.state.playingEpisode != nil {
                ProgressStatusBar(currPos: currTime, totalLength: totalTime)
            }
            
            HStack{
                PodcastImageView(podcast: self.state.playingEpisode?.podcast, size: 70, cornerRadiusScale: 0.0)
                
                VStack(alignment: .leading) {
                    Text(self.state.playingEpisode?.title ?? "Nothing Playing")
                        .font(.footnote)
                        .bold()
                        .lineLimit(1)
                    if self.state.playingEpisode != nil {
                        Text(getHHMMSSFromSec(sec: Int(self.currTime)))
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                RecordAudioButton().padding(.trailing)
                CreateBookmarkButton().padding(.trailing)
                PlayButton(episode: self.state.playingEpisode ?? PodcastEpisode())
                    .padding(.trailing)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJCUSTOM")), perform: { out in
            let player: PodcastPlayer = (out.object as! PodcastPlayer)
            self.currTime = player.currTime
            self.totalTime = player.totalTime
        })
    }
    
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            //NowPlayingStatusView(episode: Episode())
            NowPlayingStatusView()
        }
    }
}
