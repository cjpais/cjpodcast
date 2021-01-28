//
//  SpeedControlButton.swift
//  cjpodcast
//
//  Created by CJ Pais on 8/2/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct SpeedControlButton: View {
    
    @EnvironmentObject var state: PodcastState
    @Binding var speed: Float
    var size: CGFloat
    
    var body: some View {
        Button(action: {
            switch speed {
            case 1.0: speed = 1.5; break
            case 1.5: speed = 2.0; break
            case 2.0: speed = 2.5; break
            case 2.5: speed = 1.0; break
            default: speed = 1.0; break
            }
            
            state.setPlaybackSpeed(speed: speed)
        }) {
            Text(String(format: "%.1fx", speed))
                .bold()
                .font(.system(size: size))
                .foregroundColor(.white)
        }
    }
}

struct SpeedControlButton_Previews: PreviewProvider {
    static var previews: some View {
        SpeedControlButton(speed: .constant(Float(2.0)), size: 20)
    }
}
