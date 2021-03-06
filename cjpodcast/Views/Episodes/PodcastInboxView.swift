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
        List {
            ForEach(episodes) { episode in
                HStack {
                    PodcastEpisodeListItemView(episode: PodcastEpisode(episode)).padding(.vertical, 3)
                    Spacer()
                    Button(action: {
                        if self.state.isEpisodeInQueue(episode: PodcastEpisode(episode)) {
                            self.state.removeEpisodeFromQueue(episode: PodcastEpisode(episode))
                        } else
                        {
                            self.state.addEpisodeToQueue(episode: PodcastEpisode(episode))
                        }
                    }) {
                        Image(systemName: self.state.isEpisodeInQueue(episode: PodcastEpisode(episode)) ? "minus" : "plus")
                            .font(.system(size:20))
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
            .onDelete(perform: removeEpisode)
        }
        .navigationBarTitle("Listen")
        .navigationBarItems(trailing: refreshButton)
    }
    
    func removeEpisode(at offsets: IndexSet) {
        print("remove")
        for index in offsets {
            print(index)
            let episode = episodes[index]
            managedObjectContext.delete(episode)
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
    var refreshButton: some View {
        Button(action: {
            self.state.getNewEps()
        })
        {
            Image(systemName: "arrow.2.circlepath")
        }.padding()
    }
    
}

struct PodcastInboxView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastInboxView()
    }
}
