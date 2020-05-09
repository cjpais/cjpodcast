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
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                NavigationView {
                    List {
                        NavigationLink(destination: SearchView(searchViewModel: SearchViewModel())) {
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
                }
                NowPlayingStatusView(episode: self.state.playingEpisode)
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
