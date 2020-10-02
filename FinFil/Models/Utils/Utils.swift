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
    
    // 获得本App的版本号
    static func getAppVersion() -> String {
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"]
        let versionStr = version as! String
        
        return "Version " + versionStr
    }
    
    // 获得操作系统版本
    static func getIosVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    // 拿到硬件类型
    static func getDevice() -> String {
        return UIDevice.deviceType
    }
    
    // 得到appDelegate的单例对象
    func getAppDelegate() -> AppDelegate {
        // 获取Appdelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate
    }
    
    // 得到侧边栏菜单的数字flag
    func getMenuInt() -> Int {
        return getAppDelegate().sideMenuInt
    }
    
    // 设置侧边栏菜单的数字flag
    func setMenuInt(int: Int) {
        getAppDelegate().sideMenuInt = int
    }
    
    // 返回语言类型String
    func getLanguageType(_ string: String) -> String {
        // 优先级别：日语>汉语>英语，默认日语
        // 中国：zh-CN，日本：ja-JP，美国：en-US
        var type: String = "ja-JP"
        
        // 先看英语
        for (_, value) in string.enumerated() {
            if (value < "\u{4E00}") {
                type = "en-US"
            }
        }
        
        // 再看汉语
        for (_, value) in string.enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FAf}") {
                type = "zh-CN"
            }
        }
        
        // 最后日语
        for (_, value) in string.enumerated() {
            // 有平假名
            if ("\u{3040}" <= value  && value <= "\u{309f}") {
                type = "ja-JP"
            }
            
            // 有片假名
            if ("\u{30a0}" <= value  && value <= "\u{30ff}") {
                type = "ja-JP"
            }
        }
        
        return type
    }
    
    // 只有OK键的提示
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
    
    // 只有OK键，有题头和细节的提示
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
    
    // 有OK和Cancel的提示
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
    
    // 开始等待
    func startActivityIndicator() {
        // 获得窗口
        let root = UIApplication.shared.delegate as! AppDelegate
        let backFrame = (root.window?.frame)!
        
        // 覆盖整个背景
        let backView = UIView(frame: backFrame)
        backView.backgroundColor = UIColor(red: 0 / 255.0,
                                           green: 0 / 255.0,
                                           blue: 0 / 255.0,
                                           alpha: 0.5)
        backView.isUserInteractionEnabled = true
        backView.tag = ViewTag.Utils_BackView_Tag
        
        // 中间的小区
        let showWidth: CGFloat = 120
        let showHeight = showWidth
        let showX = (backView.frame.width - showWidth) / 2
        let showY = (backView.frame.height - showHeight) / 2
        //
        let showView = UIView(frame: CGRect(x: showX, y: showY,
                                            width: showWidth,
                                            height: showHeight))
        showView.backgroundColor = UIColor.clear // 可显示
        showView.layer.cornerRadius = 10
        showView.layer.masksToBounds = true
        backView.addSubview(showView)
        
        // 旋转方案一
        let indiWidth: CGFloat = 100 // 大小要统一
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
    
    // 结束等待
    func stopActivityIndicator() {
        let root = UIApplication.shared.delegate as! AppDelegate
        for subview in (root.window?.subviews)! {
            if subview.tag == ViewTag.Utils_BackView_Tag {
                subview.removeFromSuperview()
            }
        }
    }
}
