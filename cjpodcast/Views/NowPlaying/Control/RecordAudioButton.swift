//
//  RecordAudioButton.swift
//  cjpodcast
//
//  Created by CJ Pais on 7/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct RecordAudioButton: View {
    
    @State var size: CGFloat = 25
    
    var body: some View {
        Button(action: {
        })
        {
            Image(systemName: "mic.fill")
                .font(.system(size: size))
                .foregroundColor(.white)
        }
    }
}

struct RecordAudioButton_Previews: PreviewProvider {
    static var previews: some View {
        RecordAudioButton()
    }
}
