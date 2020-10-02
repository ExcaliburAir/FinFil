//
//  NetworkData.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/1.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class MovieInfo: NSObject {
    var movieID: String = ""
    var originalTitle: String = ""
    var overview: String = ""
    var releaseDate: String = ""
    
    init(dic: Dictionary<String, Any>) {
        super.init()
        
        if let value = dic["id"] {
            movieID = String(value as! Int)
        }
        if let value = dic["original_title"] {
            originalTitle = value as! String
        }
        if let value = dic["overview"] {
            overview = value as! String
        }
        if let value = dic["release_date"] {
            releaseDate = value as! String
        }
    }
}

class MovieDetail: NSObject {
    var movieID: String = ""
    var originalTitle: String = ""
    var overview: String = ""
    var releaseDate: String = ""
    var originalLanguage: String = ""
    var runtime: String = ""
    var voteAverage: String = ""
    var voteCount: String = ""
    var posterPath: String = ""
    
    init(dic: Dictionary<String, Any>) {
        super.init()
        
        if let value = dic["id"] {
            movieID = String(value as! Int)
        }
        if let value = dic["original_title"] {
            originalTitle = value as! String
        }
        if let value = dic["overview"] {
            overview = value as! String
        }
        if let value = dic["release_date"] {
            releaseDate = value as! String
        }
        if let value = dic["original_language"] {
            originalLanguage = value as! String
        }
        if let value = dic["runtime"] {
            runtime = String(value as! Int)
        }
        if let value = dic["vote_average"] {
            voteAverage = String(value as! Double)
        }
        if let value = dic["vote_count"] {
            voteCount = String(value as! Int)
        }
        if let value = dic["poster_path"] { //todo:
            posterPath = Network.imageBaseUrl + (value as! String)
        }
    }
}
