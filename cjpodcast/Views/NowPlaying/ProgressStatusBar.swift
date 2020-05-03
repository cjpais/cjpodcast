//
//  ProgressStatusBar.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/2/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct ProgressStatusBar: View {
    
    var currPos: CGFloat
    var totalLength: CGFloat
    var height: CGFloat = 3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width * (self.currPos/self.totalLength))
                    .zIndex(1)
                Rectangle()
                    .foregroundColor(.gray)
            }
        }
        .frame(height: height)
    }
}

struct ProgressStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressStatusBar(currPos: 50, totalLength: 150)
    }
}
