//
//  PodcastEpisodeListItemView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastEpisodeListItemView: View {
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                Rectangle()
                    .frame(width: 75, height: 75)
                VStack(alignment: .leading) {
                    Text("This American Life: 699").font(.headline)
                    Text("Description").font(.caption)
                    Spacer()
                }
            }
            Spacer()
            Image(systemName: "play.fill")
                .font(.largeTitle)
        }
    }
}

struct PodcastEpisodeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodeListItemView()
    }
}
