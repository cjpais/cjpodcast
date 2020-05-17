//
//  PodcastPlayer.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/27/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import AVKit

class PodcastPlayer {
   
    var currTime: CGFloat = 0
    var totalTime: CGFloat = .greatestFiniteMagnitude
    
    func tickObserver(time: CMTime) {
        currTime = CGFloat(time.seconds)
        notify()
    }
    
    func notify() {
        let not = Notification(name: .init(rawValue: "CJCUSTOM"), object: self)
        NotificationCenter.default.post(not)
    }

}
