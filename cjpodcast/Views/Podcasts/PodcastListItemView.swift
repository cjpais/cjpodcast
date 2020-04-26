//
//  PodcastListItemView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct PodcastListItemView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var state: PodcastState
    @State var podcast: Podcast
    
    var body: some View {
        HStack {
            Image(uiImage: podcast.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(podcast.title)
                Text(podcast.publisher).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            subscribeButton
        }
    }
    
    var subscribeButton: some View {
        Button(action: {
            print(self.podcast.subscribed)
            self.podcast.subscribed.toggle()
            print(self.podcast.subscribed)
            if self.podcast.subscribed {
                let newSub = PersistentPodcast(context: self.managedObjectContext)
                newSub.fromPodcast(podcast: self.podcast)

                do {
                    try self.managedObjectContext.save()
                    print("saved")
                } catch {
                    print(error)
                }
            } else {
                print("not subbed")
                do {
                    let unsubReq = PersistentPodcast.getByTitle(title: self.podcast.title)
                    let unsubPodcast = try self.managedObjectContext.fetch(unsubReq)
                    
                    for pod in unsubPodcast {
                        self.managedObjectContext.delete(pod)
                    }
                    
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        })
        {
            if self.podcast.subscribed {
                Text("unsubscribe").foregroundColor(.red)
            } else {
                Text("subscribe").foregroundColor(.green)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }

}

struct PodcastListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastListItemView(podcast: Podcast())
    }
}
