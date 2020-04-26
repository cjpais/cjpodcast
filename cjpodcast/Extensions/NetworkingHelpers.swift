//
//  NetworkingHelpers.swift
//  cjpodcast
//
//  Created by CJ Pais on 4/25/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation
import UIKit

func downloadImage(from url: URL, userdata: Any?, completed: @escaping (_ image: UIImage, _ userdata: Any?) -> () ) {

    URLSession.shared.dataTask(with: url) { data, response, error in
        if data != nil {
            DispatchQueue.main.async {
                completed(UIImage(data: data!)!, userdata)
            }
        }
    }.resume()
    
}
