//
//  SettingsView.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var state: PodcastState

    /*
    init() {
        let ud = UserDefaults()
        self.toggle = ud.object(forKey: "path") as! Bool ?? false
    }*/
    
    var body: some View {
        VStack {
            Toggle("Dev Path", isOn: self.$state.path)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
