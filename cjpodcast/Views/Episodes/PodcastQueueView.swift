//
//  PodcastQueueView.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/23/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastQueueView: View {
    @EnvironmentObject var state: PodcastState
    
    var body: some View {
        ZStack(alignment: .top) {
            List {
                ForEach(state.episodeQueue) { episode in
                    HStack {
                        SpotifyListItem(episode: episode)
                            .padding(.vertical, 3)
                    }
                }
                .onDelete(perform: removeEpisode)
                .onMove(perform: move)
            }
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("Listening Queue")

        }
    }
    
    func removeEpisode(at offsets: IndexSet) {
        print("removing ep")
        for index in offsets {
            print("should remove episode")
            let episode = self.state.episodeQueue[index]
            self.state.removeEpisodeFromQueue(episode: episode)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.state.episodeQueue.move(fromOffsets: source, toOffset: destination)
    }
}

struct PodcastQueueView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastQueueView()
    }
}
