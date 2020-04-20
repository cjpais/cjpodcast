//
//  ContentView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: PodcastSearchView()) {
                        Text("Podcast Search")
                    }
                    NavigationLink(destination: PodcastSubscriptionView()) {
                        Text("Podcast Subscriptions")
                    }
                    NavigationLink(destination: PodcastInboxView()) {
                        Text("Podcast Inbox")
                    }
                }
                .navigationBarTitle("Podcasts")
    
                NowPlayingView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
