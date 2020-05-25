//
//  PodcastSearchResultsView.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/3/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastSearchResultsView: View {
    
    var podcasts: [Podcast]
    @ObservedObject var model: SearchViewModel
    
    var body: some View {
        List() {
            ForEach(podcasts, id: \.self) { podcast in
                PodcastListItemView(podcast: podcast)
            }
        }
    }
}

struct PodcastSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastSearchResultsView(podcasts: [Podcast](), model: SearchViewModel())
    }
}
