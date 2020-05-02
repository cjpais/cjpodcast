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
        VStack {
            NavigationView {
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
            }
            /*
            BottomSheetView(isOpen: $open, maxHeight: 810, content: {
                if self.open {
                    NowPlayingControlView()
                } else {
                    NowPlayingStatusView()
                        .padding(.trailing)
                        .padding(.bottom, 30)
                }
            })
            .onTapGesture {
                if self.open == false {
                    self.open.toggle()
                }
            }*/
            Spacer()
            
            NowPlayingStatusView()
            .contentShape(Rectangle())
            .padding([.trailing])
            .background(Color(UIColor.systemGray6))
            .sheet(isPresented: $open, onDismiss: {}) {
                NowPlayingControlView()
                    .padding()
                    .environmentObject(self.state)
            }
            .onTapGesture {
                self.open.toggle()
                print(self.open)
            }
            .gesture(drag)
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
