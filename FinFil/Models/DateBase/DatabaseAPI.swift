//
//  DatabaseAPI.swift
//  FinFil
//
//  Created by tyoketusetu on 2020/10/02.
//  Copyright © 2020 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class MovieInfoRealmTool: Object {
    
    private class func getDB() -> Realm {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/defaultDB.realm")
        // setup DB
        let defaultRealm = try! Realm(fileURL: URL.init(string: dbPath)!)
        return defaultRealm
    }
    
    static func transData(_ movieDetail: MovieDetail) -> LikedMovieInfo {
        let movieInfo = LikedMovieInfo()
        movieInfo.movieIdInt = Int(movieDetail.movieID) ?? 0
        movieInfo.originalTitle = movieDetail.originalTitle
        movieInfo.overview = movieDetail.overview
        movieInfo.releaseDate = movieDetail.releaseDate
        
        return movieInfo
    }
}

extension MovieInfoRealmTool {
   
    // insert
    public class func insertMovieInfo(movieInfo: LikedMovieInfo) -> Void {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(movieInfo)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
    // read
    public class func getMovieInfos() -> Results<LikedMovieInfo> {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(LikedMovieInfo.self)
    }
    
    // update
    public class func updateMovieInfo(movieInfo: LikedMovieInfo) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(movieInfo, update: .all)
        }
    }
    
    // delete
    public class func deleteMovieInfo(movieInfo: LikedMovieInfo) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.delete(movieInfo)
        }
    }
    
    // if instance had saved in DB
    public class func ifInMovieInfoDB(movieIdInt: Int) -> Bool {
        var idList: [Int] = []
        let likedMovieInfos = MovieInfoRealmTool.getMovieInfos()
        for movieInfo in likedMovieInfos {
            idList.append(movieInfo.movieIdInt)
        }
        
        if idList.contains(movieIdInt) {
            return true
        }
        else {
            return false
        }
    }
    
    // get all instance in DB
    public class func getAll() -> [LikedMovieInfo] {
        var list: [LikedMovieInfo] = []
        let likedMovieInfos = MovieInfoRealmTool.getMovieInfos()
        for movieInfo in likedMovieInfos {
            list.append(movieInfo)
        }
        
        return list
    }
}
