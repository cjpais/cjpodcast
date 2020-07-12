//
//  PodcastSubscriptionView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastSubscriptionView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistentPodcast.getAll()) var podcasts:FetchedResults<PersistentPodcast>
    
    @EnvironmentObject var state: PodcastState
    
    var body: some View {
        List() {
            ForEach(podcasts) { podcast in
                NavigationLink(destination: PodcastEpisodesView(podcast: podcast)) {
                    PodcastListItemView(podcast: Podcast(podcast: podcast))
                }
            }
        }.navigationBarTitle("Subscriptions")
    }
}

struct PodcastSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastSubscriptionView()
    }
}
