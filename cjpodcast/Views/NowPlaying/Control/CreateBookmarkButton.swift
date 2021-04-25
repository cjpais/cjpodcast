//
//  CreateBookmarkButton.swift
//  cjpodcast
//
//  Created by CJ Pais on 7/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct CreateBookmarkButton: View {
    
    @EnvironmentObject var state: PodcastState
    @State var size: CGFloat = 30
    
    var body: some View {
        Button(action: {
            _  = self.state.addBookmark()
        })
        {
            Image(systemName: "pencil")
                .font(.system(size: size))
                .foregroundColor(.white)
        }
    }
}

struct CreateBookmarkButton_Previews: PreviewProvider {
    static var previews: some View {
        CreateBookmarkButton()
    }
}
