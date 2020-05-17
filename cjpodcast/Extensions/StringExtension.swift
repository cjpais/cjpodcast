//
//  StringExtension.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

extension String {
    func urlEncode() -> String {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)!
    }
    
    func stripHTML() -> String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
}
