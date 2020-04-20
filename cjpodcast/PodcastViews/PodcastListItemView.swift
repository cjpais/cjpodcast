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
    @State var podcast: PodcastResults
    @State var subscribed: Bool = false
    
    var body: some View {
        HStack {
            Text(podcast.title)
            Spacer()
            Button(action: {
                self.subscribed.toggle()
                if self.subscribed {
                    let newSub = Podcast(context: self.managedObjectContext)
                    newSub.title = self.podcast.title
                    newSub.listenNotesPodcastId = self.podcast.listenNotesPodcastId
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                } else {
                    print("not subbed")
                    do {
                        let unsubPodcast = try Podcast.getByTitle(title: self.podcast.title).execute()
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
                if subscribed {
                    Text("unsubscribe").foregroundColor(.red)
                } else {
                    Text("subscribe").foregroundColor(.green)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct PodcastListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastListItemView(podcast: PodcastResults())
    }
}
