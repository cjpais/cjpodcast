//
//  ContentView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var state: PodcastState
    @State private var open: Bool = false
    @State private var model: SearchViewModel = SearchViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                NavigationView {
                    List {
                        NavigationLink(destination: SearchView(searchViewModel: self.model)) {
                            Text("Podcast Search")
                        }
                        NavigationLink(destination: PodcastSubscriptionView()) {
                            Text("Podcast Subscriptions")
                        }
                        NavigationLink(destination: PodcastInboxView()) {
                            Text("Podcast Inbox")
                        }
                        NavigationLink(destination: PodcastQueueView()) {
                            Text("Podcast Queue")
                        }
                        NavigationLink(destination: FavoriteEpisodesView()) {
                            Text("Favorite Podcast Episodes")
                        }
                    }
                    .navigationBarTitle("Podcasts")
                    .navigationBarItems(trailing: self.settingsButton)
                }
                NowPlayingStatusView()
                    .contentShape(Rectangle())
                    .padding(.top, 0)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    .background(Color(UIColor.systemGray6))
                    .sheet(isPresented: self.$open, onDismiss: {}) {
                        NowPlayingControlView()
                            .padding()
                            .environmentObject(self.state)
                    }
                    .onTapGesture {
                        self.open.toggle()
                        print(self.open)
                    }
                    .gesture(self.drag)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gear").font(.custom("hi", size: 24.0))
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onEnded({_ in
                self.open.toggle()
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
