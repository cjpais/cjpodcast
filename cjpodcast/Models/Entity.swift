//
//  Entity.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

struct Entity<T: Encodable>: Encodable {
    
    var type: String
    var data: T
    
}
