//
//  BookmarkedEpisodeView.swift
//  cjpodcast
//
//  Created by CJ Pais on 7/26/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct BookmarkedEpisodeView: View {
    
    var episode: PodcastEpisode

    var body: some View {
        HStack(alignment: .top) {
            PodcastImageView(podcast: episode.podcast, size: 80)
            VStack (alignment: .leading) {
                Text(episode.title).lineLimit(2)
                Spacer()
                Text("\(episode.bookmarks.count) Bookmarks")
            }
        }
    }
    
}

struct BookmarkedEpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkedEpisodeView(episode: PodcastEpisode())
    }
}
