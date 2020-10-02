//
//  NetworkData.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/1.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import UserNotifications

enum NetworkingStatus {
    
    case mobile
    case wifi
    case none
    
    var description: String {
        switch self {
        case .mobile:
            return NSLocalizedString("Network_networkType_4G", comment: "")
        case .wifi:
            return NSLocalizedString("Network_networkType_WIFI", comment: "")
        case .none:
            return NSLocalizedString("Network_networkType_Error", comment: "")
        }
    }
}


// 网络状态监听
extension Network {
    
    static var showTips = false
    static var oldStatus: NetworkingStatus = .none
    static var status: NetworkingStatus = .none
    
    // 开始监听网络状态
    class func startListenNetwork() {
        // 监听单例
        let manager = NetworkReachabilityManager()
        manager?.listener = { status in
            self.oldStatus = self.status
            
            switch status {
            case .unknown:
                self.status = .none
            case .notReachable:
                self.status = .none
            case .reachable:
                if manager?.isReachableOnWWAN ?? false {
                    self.status = .mobile
                } else if manager?.isReachableOnEthernetOrWiFi ?? false {
                    self.status = .wifi
                }
            }
            
            if showTips {
                // 给提示
                if self.status == .none {
                    Network.postAPNsMessage(title: NSLocalizedString("Network_error", comment: ""),
                                            body: self.status.description)
                }
                else {
                    Network.postAPNsMessage(title: NSLocalizedString("Network_networkStatu", comment: ""),
                                            body: self.status.description)
                }
            }
            else {
                showTips = true
            }
            print("networing == ", self.status.description)
        }
        
        manager?.startListening()
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if status == .none {
                showTips = true
                
                // 给提示
                Network.postAPNsMessage(title: NSLocalizedString("Network_error", comment: ""),
                                        body: self.status.description)
            }
        })
    }
    
    // 程序内部发送提示
    class func postAPNsMessage(title: String, body: String) {
        // controlled in setting viewcontroller
        if DefaultBase().getAppType() == DefaultBase.unLiseningNetwork {
            return
        }
        
        // 设置消息
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        content.badge = 0 // icon右上角显示多少提示

        // 指定时间发送通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // 用trigger和content创建请求
        let request = UNNotificationRequest(identifier: "App_Network_Status", content: content, trigger: trigger)
        
        // 把请求添加到系统队列中
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Failed to add request to notification center. error:\(error)")
            }
        }
    }
    
    // 主动判断是否连接
    class func ifNetConnect() -> Bool {
        if self.status == .none {
            return false
        }
        else {
            return true
        }
    }
}
