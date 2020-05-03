//
//  PodcastImageView.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/2/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastImageView: View {
    
    var podcast: Podcast?
    var size: CGFloat
    
    var cornerRadiusScale: CGFloat = 0.03

    var body: some View {
        ZStack {
            if self.podcast != nil {
                Image(uiImage: self.podcast!.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .cornerRadius(cornerRadiusScale * self.size)
            } else {
                Rectangle()
                    .frame(width: size, height: size)
            }
        }
    }
}

struct PodcastImageView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastImageView(podcast: Podcast(), size: 50)
    }
}
