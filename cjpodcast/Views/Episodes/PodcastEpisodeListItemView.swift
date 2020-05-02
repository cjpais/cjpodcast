//
//  PodcastEpisodeListItemView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastEpisodeListItemView: View {
    
    @EnvironmentObject var state: PodcastState
    @State var playing: Bool = false
    var episode: Episode

    var body: some View {
        HStack(alignment: .center) {
            if episode.podcast != nil {
                Image(uiImage: episode.podcast!.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75, height: 75)
            } else {
                Rectangle()
                    .frame(width: 75, height: 75)
            }
            VStack(alignment: .leading) {
                Text(episode.title)
                    .font(.headline)
                Text(episode.published_date.description)
                Spacer()
                Text(episode.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            Spacer()
            PlayButton(episode: episode)
        }
    }
}

struct PodcastEpisodeListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodeListItemView(episode: Episode())
    }
}
