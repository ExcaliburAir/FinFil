//
//  UserDefaultBase.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/3.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

// MARK:- 字段Key，一旦制成，绝不可改
class UserDefaultBase: NSObject {
    static let soundType = "App_sound_type"
    static let soundOn = "App_sound_on"
    static let soundOff = "App_sound_off"
    
    static let appType = "App_Type"
    static let listeningNetwork = "App_listeningNetwork_type"
    static let unLiseningNetwork = "App_unLiseningNetwork_type"
}

extension UserDefaultBase {
    // use in UserDefaultBase for save
    private func setBase(value: String, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    // use in UserDefaultBase for read
    private func getBase(key: String) -> String {
        let value = UserDefaults.standard.string(forKey: key)
        
        if (value != nil) {
            return value!
        } else {
            print("parameter wrrong: " + key + " is nil.")
            return ""
        }
    }
    
    // set the sond on or off
    func setSoundType(string: String) {
        setBase(value: string, key: UserDefaultBase.soundType)
    }
    
    // get if the song on or off
    func getSoundType() -> String {
        return getBase(key: UserDefaultBase.soundType)
    }
    
    // set if read text by audio
    func setAppType(string: String!) {
        setBase(value: string, key: UserDefaultBase.appType)
    }
    // get if read text by audio
    func getAppType() -> String {
        return getBase(key: UserDefaultBase.appType)
    }
}
