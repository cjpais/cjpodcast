//
//  SearchBarView.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/3/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct SearchBarView: View {
    
    @ObservedObject var model: SearchViewModel
    var searchType: SearchViewModel.SearchType
    @Binding var query: String
    @State var action: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading)
            TextField("Search \(searchType.stringPluralUpper)", text: $query, onCommit: {
                print("on commit")
                self.action()
            })
                .font(Font.system(size: 18))
                .padding(.vertical, 7)
            Button(action: {
                self.query = ""
                self.model.clear()
            })
            {
                Image(systemName: "xmark.circle.fill")
            }
            .foregroundColor(.gray)
            .padding(.trailing)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(11)
        .padding([.bottom, .horizontal])
    }
    

}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(model: SearchViewModel(), searchType: .podcasts, query: .constant("")) {
            
        }
    }
}
