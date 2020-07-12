//
//  BookmarksView.swift
//  cjpodcast
//
//  Created by CJ Pais on 7/11/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import SwiftUI

struct BookmarksView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistentBookmark.getAll()) var bookmarks:FetchedResults<PersistentBookmark>
    
    var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                Text(getHHMMSSFromSec(sec: Int(truncating: bookmark.atTime!)))
            }
            .onDelete(perform: removeBookmark)
        }
    }
    
    func removeBookmark(at offsets: IndexSet) {
        for index in offsets {
            let bookmark = bookmarks[index]
            managedObjectContext.delete(bookmark)
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
    }
}
