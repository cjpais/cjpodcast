//
//  Streamable.swift
//  cjpodcast
//
//  Created by CJ Pais on 8/22/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

protocol Streamable: Encodable {
    func getDataStream<T>() -> DataStream<T>
}
