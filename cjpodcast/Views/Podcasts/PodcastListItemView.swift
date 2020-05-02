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
            SubscribeButton(podcast: podcast, subscribed: podcast.subscribed)
        }
    }
}

struct PodcastListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastListItemView(podcast: Podcast())
    }
}
