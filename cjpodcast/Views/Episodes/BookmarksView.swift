//
//  BookmarksView.swift
//  cjpodcast
//
//  Created by CJ Pais on 7/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct BookmarksView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistentEpisode.getAllBookmarked()) var bookmarkedEpisodes:FetchedResults<PersistentEpisode>
    
    var body: some View {
        List {
            ForEach(bookmarkedEpisodes) { episode in
                SpotifyListItem(episode: PodcastEpisode(episode))
            }
        }.navigationBarTitle("Bookmarked Episodes")
    }
    
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
    }
}
