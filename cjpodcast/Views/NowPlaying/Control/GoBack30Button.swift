//
//  Backwards30.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/2/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct GoBack30Button: View {
    @EnvironmentObject var state: PodcastState
    var size: CGFloat = 30
    
    var body: some View {
        Button(action: {
            self.state.back(numSec: 30)
        })
        {
            Image(systemName: "gobackward.30")
                .font(.system(size: size))
                .foregroundColor(.white)
        }.padding()
        
    }
}

struct Backwards30_Previews: PreviewProvider {
    static var previews: some View {
        GoBack30Button()
    }
}
