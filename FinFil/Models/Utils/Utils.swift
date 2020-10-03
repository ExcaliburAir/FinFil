//
//  Utils.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import AVFoundation

class Utils: NSObject {
    
    // get app viersion number
    static func getAppVersion() -> String {
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"]
        let versionStr = version as! String
        
        return "Version " + versionStr
    }
    
    // get iOS version
    static func getIosVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    // get device type
    static func getDevice() -> String {
        return UIDevice.deviceType
    }
    
    // get appDelegate instance
    func getAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    
    // get side menu flag
    func getMenuInt() -> Int {
        return getAppDelegate().sideMenuInt
    }
    
    // set side menu flag
    func setMenuInt(int: Int) {
        getAppDelegate().sideMenuInt = int
    }
    
    // get language type : english, japanese, chinese.
    func getLanguageType(_ string: String) -> String {
        // japanese > chinese > english ,defult is japanese
        // chinese：zh-CN，japanese：ja-JP，english：en-US
        var type: String = "ja-JP"
        
        // english
        for (_, value) in string.enumerated() {
            if (value < "\u{4E00}") {
                type = "en-US"
            }
        }
        
        // chinese
        for (_, value) in string.enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FAf}") {
                type = "zh-CN"
            }
        }
        
        // japnese
        for (_, value) in string.enumerated() {
            // hiragana
            if ("\u{3040}" <= value  && value <= "\u{309f}") {
                type = "ja-JP"
            }
            
            // katagana
            if ("\u{30a0}" <= value  && value <= "\u{30ff}") {
                type = "ja-JP"
            }
        }
        
        return type
    }
    
    func ifOnlyEnglish(_ string: String) -> Bool {
        for (_, value) in string.enumerated() {
            if (value >= "\u{4E00}") {
                return false
            }
        }
        
        return true
    }
    
    func ifOnlyWordAndNumber(_ string: String) -> Bool {
        let labStr = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890 "
        for char in string {
            if !labStr.contains(char) {
                return false
            }
        }
        
        return true
    }
    
    // get alertview only have OK button
    func okButtonAlertView(title: String, controller: UIViewController, block: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if (block != nil) {
                block!()
            }
        })
        alert.addAction(ok)
        controller.present(alert, animated: true, completion: nil)
    }
    
    // get alertview only have OK button, title and message
    func okButtonAlertView(title: String, message: String,
                           controller: UIViewController, block: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if (block != nil) {
                block!()
            }
        })
        alert.addAction(ok)
        controller.present(alert, animated: true, completion: nil)
    }
    
    // get alertview with OK and Cancel button
    func okCancelAlertView(title: String, controller: UIViewController, okBlock: (() -> Void)?, cancelBlock: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            if (cancelBlock != nil) {
                cancelBlock!()
            }
        })
        alert.addAction(cancel)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if (okBlock != nil) {
                okBlock!()
            }
        })
        alert.addAction(ok)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    // start activity indicator
    func startActivityIndicator() {
        // cover to window
        let root = UIApplication.shared.delegate as! AppDelegate
        let backFrame = (root.window?.frame)!
        
        // window size
        let backView = UIView(frame: backFrame)
        backView.backgroundColor = UIColor(red: 0 / 255.0,
                                           green: 0 / 255.0,
                                           blue: 0 / 255.0,
                                           alpha: 0.5)
        backView.isUserInteractionEnabled = true
        backView.tag = ViewTag.Utils_BackView_Tag
        
        // background view
        let showWidth: CGFloat = 120
        let showHeight = showWidth
        let showX = (backView.frame.width - showWidth) / 2
        let showY = (backView.frame.height - showHeight) / 2
        //
        let showView = UIView(frame: CGRect(x: showX, y: showY,
                                            width: showWidth,
                                            height: showHeight))
        showView.backgroundColor = UIColor.clear
        showView.layer.cornerRadius = 10
        showView.layer.masksToBounds = true
        backView.addSubview(showView)
        
        // indicator
        let indiWidth: CGFloat = 100
        let indiHeight: CGFloat = indiWidth
        let indiX: CGFloat = (showWidth - indiWidth) / 2
        let indiY: CGFloat = (showHeight - indiHeight) / 2
        let indicatorFrame = CGRect(x: indiX,
                                    y: indiY,
                                    width: indiWidth,
                                    height: indiHeight)
        let activityIndicatorView = NVActivityIndicatorView(
            frame: indicatorFrame,
            type: .circleStrokeSpin,
            color: UIColor.white,
            padding: 0)
        showView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        root.window?.addSubview(backView)
    }
    
    // stop activity indicator
    func stopActivityIndicator() {
        let root = UIApplication.shared.delegate as! AppDelegate
        for subview in (root.window?.subviews)! {
            if subview.tag == ViewTag.Utils_BackView_Tag {
                subview.removeFromSuperview()
            }
        }
    }
}
