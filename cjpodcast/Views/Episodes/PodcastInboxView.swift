//
//  PodcastInboxView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastInboxView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistentEpisode.getAll()) var episodes:FetchedResults<PersistentEpisode>
    @EnvironmentObject var state: PodcastState
    
    var body: some View {
        List() {
            ForEach(episodes) { episode in
                PodcastEpisodeListItemView(episode: Episode(episode))
            }
        }
        .navigationBarTitle("Listen")
    }
}

struct PodcastInboxView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastInboxView()
    }
}
