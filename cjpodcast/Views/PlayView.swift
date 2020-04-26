//
//  PlayView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PlayView: View {
    
    @State private var play: Bool = false
    @EnvironmentObject var player: PodcastState
    @State private var loaded: Bool = false
    
    var body: some View {
        VStack {
            Text("This American Life 699").font(.largeTitle)
            
            HStack {
                Button(action: {
                    self.player.currTime -= 30
                    self.player.seek(time: self.player.currTime)
                })
                {
                    Image(systemName: "gobackward.30").scaleEffect(2.0)
                }.padding()
                
                Button(action: {
                    self.loaded = self.player.isLoaded
                    self.play.toggle()
                    self.player.action(play: self.play)
                })
                {
                    if play {
                        Image(systemName: "pause.fill").scaleEffect(4.0)
                    } else {
                        Image(systemName: "play.fill").scaleEffect(4.0)
                    }
                }.padding()
                
                Button(action: {
                    self.player.currTime += 30
                    self.player.seek(time: self.player.currTime)
                })
                {
                    Image(systemName: "goforward.30").scaleEffect(2.0)
                }.padding()
            }
            Spacer()
            
            if (self.player.podcastLength > 0) {
                Slider(value: self.$player.currTime, in:0...self.player.podcastLength, step: 1, onEditingChanged: { changed in
                    self.play.toggle()
                    self.player.action(play: self.play)
                    self.player.seek(time: self.player.currTime)
                })
                Text("\(Int(self.player.currTime/60)):\(Int(self.player.currTime.truncatingRemainder(dividingBy: 60)))")
            }
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}
