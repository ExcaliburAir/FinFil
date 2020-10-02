//
//  DefaultBase.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/3.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

// MARK:- 字段Key，一旦制成，绝不可改
class DefaultBase: NSObject {
    static let soundType = "App_sound_type"
    static let soundOn = "App_sound_on"
    static let soundOff = "App_sound_off"
    
    static let appType = "App_Type"
    static let listeningNetwork = "App_listeningNetwork_type"
    static let unLiseningNetwork = "App_unLiseningNetwork_type"
}

extension DefaultBase {
    // 设置存储通用方法
    func setBase(value: String, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    // 获取存储通用方法
    func getBase(key: String) -> String {
        let value = UserDefaults.standard.string(forKey: key)
        
        if (value != nil) {
            // UserDefaultsが保存したIDをもらう
            return value!
        } else {
            print("parameter wrrong: " + key + " is nil.")
            // 最初なら""を送ります
            return ""
        }
    }
    
    // 设置,扫码成功后,的声音flag
    func setSoundType(string: String) {
        setBase(value: string, key: DefaultBase.soundType)
    }
    
    // 设置,扫码成功后,的声音flag
    func getSoundType() -> String {
        return getBase(key: DefaultBase.soundType)
    }
    
    // 设置什么模式
    func setAppType(string: String!) {
        setBase(value: string, key: DefaultBase.appType)
    }
    // 获取模式
    func getAppType() -> String {
        return getBase(key: DefaultBase.appType)
    }
}
