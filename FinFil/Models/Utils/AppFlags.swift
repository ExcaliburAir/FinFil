//
//  AppFlags.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

// side menu flags
class SelectedSideMenu: NSObject {
    static let search =         0
    static let liked =          1
    static let setting =        2
}

// use in app
class Standard: NSObject {
    static let radius: CGFloat = 5 // View radius
}

// notification type
class NotificationName: NSObject {
    static let hideKeyboard = "hideKeyboard" // hide keyboard
}

// view tag
class ViewTag: NSObject {
    // use by indicator
    static let Utils_BackView_Tag: Int = 11000001
}
