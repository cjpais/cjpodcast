//
//  SceneDelegate.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var player: PodcastState!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let contentView = ContentView().environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            // Remove the DB if we want to. (requires rebuild)
            let pMgr = PersistenceManager(context: context)
            if removeDB {
                pMgr.clearDB()
            }
            
            do {
                let podcasts = try context.fetch(PersistentPodcast.getAll())
                for podcast in podcasts {
                    if podcast.id == nil {
                        podcast.id = UUID()
                    }
                    //if podcast.id == UUID(uuidString: "AD2373AA-C1ED-4991-9212-A854B7C42DCB")! {
                        //createNewEntityOnServer(from: podcast, uuid: podcast.id!)
                    //}
                    
                }
                
                let episodes = try context.fetch(PersistentEpisode.getAll())
                for episode in episodes {
                    if episode.id == nil {
                        episode.id = UUID()
                    }

                    //createNewEntityOnServer(from: episode, uuid: episode.id!)
                    
                }
                
                let bookmarks = try context.fetch(PersistentBookmark.getAll())
                for bookmark in bookmarks {
                    if bookmark.id == nil {
                        bookmark.id = UUID()
                    }
                
                    //createNewEntityOnServer(from: bookmark, uuid: bookmark.id!)
                    
                }
                
                try context.save()
            } catch {
               print(error)
            }
            
            if UserDefaults.standard.object(forKey: "path") == nil {
                print("setting default value for the path")
                let ud = UserDefaults()
                ud.set(false, forKey: "path")
            } else {
                let ud = UserDefaults()
                print(ud.object(forKey: "path") ?? "no path")
            }

            player = PodcastState(pMgr: pMgr)
            window.rootViewController = UIHostingController(rootView: contentView.environmentObject(player))
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("SCENE DISCONNECTED")
        player.persistCurrEpisodeState()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("SCENE BECAME ACTIVE")
        print(player.playerState)
        //player.populateEpisodeQueue()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("SCENE RESIGNING ACTIVE")
        player.persistCurrEpisodeState()
        player.persistQueue()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("SCENE ENTERING FOREGROUND")
        let ud = UserDefaults()
        let lastUpdated = ud.object(forKey: "lastUpdated") as? Date ?? Date.distantPast
        
        let delta = Date().timeIntervalSince(lastUpdated)
        
        print("Last Updated at: \(lastUpdated). \(delta) Seconds Ago")
        
        if delta > sixHoursInSec {
            self.player.getNewEps()
        }
        
        self.player.getFutureQueue()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("SCENE MOVING TO BACKGROUND")

        player.persistCurrEpisodeState()
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

