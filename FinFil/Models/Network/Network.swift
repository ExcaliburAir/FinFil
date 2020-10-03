//
//  Network.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/1.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

// network api
class Network: NSObject {
    let timeOutInt: Int = 60
    static let api_key = "568f880aacea68f027ac519ac18d521e" // zhangjieshuo002
    static let imageBaseUrl = "https://image.tmdb.org/t/p/w154/"

    let searchUrl =
        "https://api.themoviedb.org/3/search/movie?api_key=" + Network.api_key + "&query="
    let detailUrl1 =
        "https://api.themoviedb.org/3/movie/"
    let detailUrl2 =
        "?api_key=" + Network.api_key
    
    // delete space in string.
    // todo:
    func clearSpace(string: String) -> String {
        var tmpString = string
        for i in 0...10 {
            var obString = ""
            for _ in 0...i {
                obString = obString + " "
            }
            tmpString = tmpString.replacingOccurrences(of: obString, with: "+")
        }
        
        return tmpString
    }
    
    // use path to get image from web
    func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?) -> ())
    {
        guard let url = URL(string: urlString) else {
            return closure(nil)
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return closure(nil)
            }
            guard response != nil else {
                print("no response")
                return closure(nil)
            }
            guard data != nil else {
                print("no data")
                return closure(nil)
            }
            DispatchQueue.main.async {
                closure(UIImage(data: data!))
            }
        }; task.resume()
    }
}

extension Network {
    // search movies by keyword
    // todo: other page, not juset page 1.
    func get_search_request(
        controller: UIViewController,
        queryString: String,
        block: ((_ data: [MovieInfo]) -> Void)?)
    {
        // start activity indicator
        Utils().startActivityIndicator()
        
        // request of URL
        let query = clearSpace(string: queryString)
        let urlString: String = searchUrl + query
        
        // setup request
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.timeoutInterval = TimeInterval(timeOutInt)
        request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
        
        // send request
        Alamofire.request(request)
            .validate()
            .responseJSON { (response: DataResponse<Any>) in
                // stop activity indicator
                Utils().stopActivityIndicator()
                // deal with result
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        print(data)
                        
                        var moviesInfo: [MovieInfo] = []
                        let dic = data as! Dictionary<String, Any>
                        let results = dic["results"] as! [Dictionary<String, Any>]
                        
                        for movie in results {
                            moviesInfo.append(MovieInfo(dic: movie))
                        }
                        
                        // return block
                        if (block != nil) {
                            _ = block!(moviesInfo)
                        }
                    }
                    else {
                        Utils().okButtonAlertView(
                            title: NSLocalizedString("Network_noResult_tryAgain", comment: ""),
                            controller: controller,
                            block: nil)
                    }
                    break
                case .failure(_):
                    print(response.result.error ?? (Any).self)
                    Utils().okButtonAlertView(
                        title: NSLocalizedString("Network_fails_tryAgain", comment: ""),
                        controller: controller,
                        block: nil)
                    
                    break
                }
        }
    }
    
    // moview deatials requset
    func get_details_request(
        controller: UIViewController,
        movieID: String,
        block: ((_ data: MovieDetail) -> Void)?)
    {
        // start activity indicator
        Utils().startActivityIndicator()
        
        // request of URL
        let urlString: String = detailUrl1 + movieID + detailUrl2
        
        // setup request
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.timeoutInterval = TimeInterval(timeOutInt)
        request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
        
        // send request
        Alamofire.request(request)
            .validate()
            .responseJSON { (response: DataResponse<Any>) in
                // stop activity indicator
                Utils().stopActivityIndicator()
                // deal with result
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        print(data)
                        
                        let dic = data as! Dictionary<String, Any>
                        if (block != nil) {
                            _ = block!(MovieDetail(dic: dic))
                        }
                    }
                    else {
                        Utils().okButtonAlertView(
                            title: NSLocalizedString("Network_noResult_tryAgain", comment: ""),
                            controller: controller,
                            block: nil)
                    }
                    break
                case .failure(_):
                    print(response.result.error ?? (Any).self)
                    Utils().okButtonAlertView(
                        title: NSLocalizedString("Network_fails_tryAgain", comment: ""),
                        controller: controller,
                        block: nil)
                    
                    break
                }
        }
    }
}
