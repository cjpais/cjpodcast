//
//  DataStream.swift
//  cjpodcast
//
//  Created by CJ Pais on 8/22/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

struct DataStream<T: Encodable>: Encodable {
    var path: String
    var name: String
    var version: String
    var data: T
}
