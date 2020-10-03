//
//  NetworkData.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/1.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

// result for search movies request
class MovieInfo: NSObject {
    var movieID: String = ""
    var originalTitle: String = ""
    var overview: String = ""
    var releaseDate: String = ""
    
    init(dic: Dictionary<String, Any>) {
        super.init()
        
        if let value = dic["id"] {
            if let id = value as? Int {
                movieID = String(id)
            }
        }
        if let value = dic["original_title"] {
            if let title = value as? String {
                originalTitle = title
            }
        }
        if let value = dic["overview"] {
            if let overviewStr = value as? String {
                overview = overviewStr
            }
        }
        if let value = dic["release_date"] {
            if let date = value as? String {
                releaseDate = date
            }
        }
    }
}

// result for deatials request
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
            if let id = value as? Int {
                movieID = String(id)
            }
        }
        if let value = dic["original_title"] {
            if let title = value as? String {
                originalTitle = title
            }
        }
        if let value = dic["overview"] {
            if let overviewStr = value as? String {
                overview = overviewStr
            }
        }
        if let value = dic["release_date"] {
            if let date = value as? String {
                releaseDate = date
            }
        }
        if let value = dic["original_language"] {
            if let language = value as? String {
                originalLanguage = language
            }
        }
        if let value = dic["runtime"] {
            if let timeInt = value as? Int {
                runtime = String(timeInt)
            }
        }
        if let value = dic["vote_average"] {
            if let average = value as? Double {
                voteAverage = String(average)
            }
        }
        if let value = dic["vote_count"] {
            if let count = value as? Int {
                voteCount = String(count)
            }
        }
        if let value = dic["poster_path"] {
            if let path = value as? String {
                posterPath = Network.imageBaseUrl + path
            }
        }
    }
}
