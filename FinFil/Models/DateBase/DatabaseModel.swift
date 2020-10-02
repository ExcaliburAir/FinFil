//
//  DatabaseModel.swift
//  FinFil
//
//  Created by tyoketusetu on 2020/10/02.
//  Copyright © 2020 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LikedMovieInfo: Object {
    @objc dynamic var movieIdInt: Int = 0
    @objc dynamic var originalTitle: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var releaseDate: String = ""
    
    override static func primaryKey() -> String? {
        return "movieIdInt"
    }
    
    override static func indexedProperties() -> [String] {
        return ["originalTitle"]
    }
}
