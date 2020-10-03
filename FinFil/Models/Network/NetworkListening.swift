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


// network listening method
extension Network {
    
    static var showTips = false
    static var oldStatus: NetworkingStatus = .none
    static var status: NetworkingStatus = .none
    
    // start to listening network
    class func startListenNetwork() {
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
                // send notice
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
                
                // send notice
                Network.postAPNsMessage(title: NSLocalizedString("Network_error", comment: ""),
                                        body: self.status.description)
            }
        })
    }
    
    // send message in app
    class func postAPNsMessage(title: String, body: String) {
        // controlled in setting viewcontroller
        if UserDefaultBase().getAppType() == UserDefaultBase.unLiseningNetwork {
            return
        }
        
        // setup message
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        content.badge = 0 // icon

        // setup send time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        // ceate request
        let request = UNNotificationRequest(identifier: "App_Network_Status", content: content, trigger: trigger)
        
        // set request in
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Failed to add request to notification center. error:\(error)")
            }
        }
    }
    
    // if conected
    class func ifNetConnect() -> Bool {
        if self.status == .none {
            return false
        }
        else {
            return true
        }
    }
}
