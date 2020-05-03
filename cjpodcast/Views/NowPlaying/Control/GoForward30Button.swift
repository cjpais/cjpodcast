//
//  GoForward30Button.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/2/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct GoForward30Button: View {
    @EnvironmentObject var state: PodcastState
    var size: CGFloat = 30
    
    var body: some View {
        Button(action: {
            self.state.forward(numSec: 30)
            })
        {
            Image(systemName: "goforward.30")
                .font(.system(size: size))
                .foregroundColor(.white)
        }.padding()
    }
}

struct GoForward30Button_Previews: PreviewProvider {
    static var previews: some View {
        GoForward30Button()
    }
}
