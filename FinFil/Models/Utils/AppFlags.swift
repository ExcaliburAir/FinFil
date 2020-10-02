//
//  AppFlags.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

// 侧边栏用：必须和侧边栏数字顺位相同
class SelectedSideMenu: NSObject {
    static let search =         0
    static let liked =          1
    static let setting =        2
}

// 整体的值标准
class Standard: NSObject {
    static let radius: CGFloat = 5 // View圆角
}

// 自定义通知name
class NotificationName: NSObject {
    static let hideKeyboard = "hideKeyboard" // 让键盘隐藏
}

// view用：统一管理ViewTag号
class ViewTag: NSObject {
    // 图像增减，单用
    static let Utils_BackView_Tag: Int = 11000001
}
