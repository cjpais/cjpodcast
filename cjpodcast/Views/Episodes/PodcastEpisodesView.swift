//
//  PodcastEpisodesView.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/18/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

let podcastEpisodesFormat: String = "https://listen-api.listennotes.com/api/v2/podcasts/%@"

struct PodcastEpisodesView: View {
    
    var podcast: PersistentPodcast
    @State private var episodes: [PersistentEpisode] = []

    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        List() {
            HStack {
                Spacer()
                PodcastImageView(podcast: Podcast(podcast: podcast), size: 200)
                Spacer()
            }
            ForEach(episodes, id: \.self) { episode in
                PodcastEpisodeListItemView(episode: PodcastEpisode(episode))
            }
        }
        .navigationBarTitle(podcast.title!)
        .navigationBarItems(trailing: refreshButton)
        .onAppear(perform: loadEpisodes)
    }
    
    var refreshButton: some View {
        Button(action: {
            self.getNewEpisodes()
        })
        {
            Image(systemName: "arrow.2.circlepath")
        }.padding()
    }
    
    private func loadEpisodes() {
        /* Get existing episodes */
        do {
            self.episodes = try managedObjectContext.fetch(PersistentEpisode.getByPodcastId(id: self.podcast.listenNotesPodcastId!))
        } catch {
            print(error)
        }
    }
    
    private func getNewEpisodes() {
        let episodesString = String(format: podcastEpisodesFormat, self.podcast.listenNotesPodcastId!)
        print("ep string: \(episodesString)")
        guard let url = URL(string: episodesString) else {
            print("invalid query: ", episodesString)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(listenNotesAPIKey, forHTTPHeaderField: "X-ListenAPI-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                if let decodedResponse = try? decoder.decode(EpisodeResults.self, from: data!) {
                    DispatchQueue.main.async {
                        let tmp = decodedResponse

                        for episode in tmp.episodes {
                            do {
                                let existingEpisodes = try self.managedObjectContext.fetch(PersistentEpisode.getByEpisodeId(id: episode.listenNotesId))
                                if existingEpisodes == [] {
                                    let newEp = PersistentEpisode(context: self.managedObjectContext)
                                    newEp.new(episode: episode, podcast: self.podcast)
                                    newEp.listenNotesPodcastId = tmp.podcastId
                                    print(self.podcast.listenNotesPodcastId)
                                    self.episodes.append(newEp)
                                } else { print("nothing new to add from this req") }
                            } catch {
                                print("error", error)
                            }

                        }
                        
                        /* Save managed object context */
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print("error saving managed obj context", error)
                        }
                        
                    }
                } else {
                    print("json decode error")
                }
            } else {
                print("data error")
            }
        }.resume()
    }
}

struct PodcastEpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastEpisodesView(podcast: PersistentPodcast())
    }
}
