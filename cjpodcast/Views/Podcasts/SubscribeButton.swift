//
//  SubscribeButton.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/1/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct SubscribeButton: View {
    
    var podcast: Podcast
    @State var subscribed: Bool = false
    @EnvironmentObject var state: PodcastState
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        Button(action: {
            self.subscribed.toggle()
            if self.subscribed {
                let newSub = PersistentPodcast(context: self.managedObjectContext)
                newSub.fromPodcast(podcast: self.podcast)
                newSub.subscribed = true

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
                        pod.subscribed = false
                    }
                    
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        })
        {
            if self.subscribed {
                Text("unsubscribe").foregroundColor(.red)
            } else {
                Text("subscribe").foregroundColor(.green)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

/*
struct SubscribeButton_Previews: PreviewProvider {
    static var previews: some View {
        SubscribeButton(podcast: Podcast())
    }
}*/
