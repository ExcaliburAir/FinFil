//
//  AppDelegate.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // 选中侧边栏的flag
    var sideMenuInt: Int = SelectedSideMenu.search
    // 语音播报用
    fileprivate let avSpeech = AVSpeechSynthesizer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 配置通知中心
        self.configUserNotification()
        // 配置语音播放
        self.configAVSpeech()
        // 配置数据库
        self.configRealm()
        // 设置侧边栏
        self.configureSideMenu()
        // 加载界面，设置参数
        self.setupApp()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

// MARK:- Configs
extension AppDelegate {

    private func setupApp() {
        // 开始网络状态监听
        Network.startListenNetwork()
        
        // 获取声音提示类型，默认为开
        let soundType = DefaultBase().getSoundType()
        if soundType.isEmpty {
            DefaultBase().setSoundType(string: DefaultBase.soundOn)
        }
        
        let appType = DefaultBase().getAppType()
        if appType.isEmpty {
            DefaultBase().setAppType(string: DefaultBase.listeningNetwork)
        }
        
        // setup root view
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        weak var sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenu") as? SideMenuController
        self.window?.rootViewController = sideMenuViewController
    }
    
    private func configureSideMenu() {
        // 侧边栏宽度
        SideMenuController.preferences.basic.menuWidth = 280
        // 侧边栏第一界面的id识别
        SideMenuController.preferences.basic.defaultCacheKey = "0"
        // 侧边栏以边接边挤出的方式调用
        SideMenuController.preferences.basic.position = .sideBySide
    }
    
    // 设置通知
    private func configUserNotification() {
        // 获得通知授权，第一次登录会提示用户开启
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { (granted, error) in
            print("Permission granted:\(granted)")
            guard granted else { return }
            
            // 异步注册本app到APNs
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        // User通知的注册要在AppDeleget内部代理
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 设置文字转语音
    private func configAVSpeech() {
        avSpeech.delegate = self
    }
    
    // 配置数据库
    private func configRealm() {
        // 如果要存储的数据模型属性发生变化,需要配置当前版本号比之前大
        let dbVersion: UInt64 = 1
        // 获得黑盒路径
        let docPath = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
            )[0] as String
        // 数据库路径加到黑盒里
        let dbPath = docPath.appending("/defaultDB.realm")
        // 配置参数迭代
        let config = Realm.Configuration(
            // 数据库的路径
            fileURL: URL.init(string: dbPath),
            inMemoryIdentifier: nil,
            syncConfiguration: nil,
            encryptionKey: nil,
            readOnly: false,
            schemaVersion: dbVersion,
            // 新老版本的数据库的更新迁移操作放在这里
            migrationBlock: { (migration, oldSchemaVersion) in

        },
            deleteRealmIfMigrationNeeded: false,
            shouldCompactOnLaunch: nil,
            objectTypes: nil
        )
        // 配置
        Realm.Configuration.defaultConfiguration = config
        // 检测更新成功与否
        Realm.asyncOpen{ (realm, error) in
            //
            if let _ = realm {
                print("Realm successed!")
            }
            else if let error = error {
                print("Realm false：\(error.localizedDescription)")
            }
        }
    }
}

// MARK:- UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 后台接收 todo: 并不总是好用
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void)
    {
        // 默认
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("Default Action")
        }
        // 消失
        else if (response.actionIdentifier == UNNotificationDismissActionIdentifier) {
            print("Dismiss action")
        }
        // 自定义
        else if (response.notification.request.content.categoryIdentifier == "calendarCategory") {
            print("Dismiss action")
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
    }
    
    // 程序内接收
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // 识别参数，传递参数
        var options: UNNotificationPresentationOptions = []
        let identifier = notification.request.identifier
        
        // 区分消息
        if identifier == "App_Network_Status" {
            // [.alert, .sound]
            options = [.alert]
        }

        completionHandler(options)
    }
}

// MARK:- AVSpeechSynthesis
extension AppDelegate {
    
    // 播放
    func startSpeek(text: String!) {
        // 永远最新优先
        if avSpeech.isSpeaking {
            cancleSpeek()
        }
        
        // 创建合成的语音类
        let utterance = AVSpeechUtterance(string: text)
        // 说话的速度
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        // 语言类型
        utterance.voice = AVSpeechSynthesisVoice(language: Utils().getLanguageType(text))
        // 说话音量, [0-1] Default = 1
        utterance.volume = 1
        // 语音合成器在当前语音结束之后处理下一个排队的语音之前需要等待的时间, 默认0.0
        utterance.postUtteranceDelay = 0.1
        // 说话的基线音高, [0.5 - 2] Default = 1
        utterance.pitchMultiplier = 1
        
        // 异步提示交易成功提示音
        if DefaultBase().getSoundType() == DefaultBase.soundOn {
            //全局队列（并发队列）异步执行，开多个线程，一起执行
            DispatchQueue.global().async {
                // 开始播放
                self.avSpeech.speak(utterance)
            }
        }
    }
    
    // 暂停
    func pauseSpeek() {
        avSpeech.pauseSpeaking(at: .immediate)
    }
    
    // 继续
    func continueSpeek() {
        avSpeech.continueSpeaking()
    }
    
    // 终止
    func cancleSpeek() {
        avSpeech.stopSpeaking(at: .immediate)
    }
}

// MARK:- AVSpeechSynthesizerDelegate
extension AppDelegate: AVSpeechSynthesizerDelegate {
    
    // 将要播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        // 阅读范围，可以显示到框框里
        let subStr = utterance.speechString.dropFirst(characterRange.location).description
        let _ = subStr.dropLast(subStr.count - characterRange.length).description
    }
    
    // 已经开始播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("speechSynthesizer didStart")
    }
    
    // 已经结束播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("speechSynthesizer didFinish")
    }
    
    // 暂停
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("speechSynthesizer didPause")
    }
    
    // 继续
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("speechSynthesizer didContinue")
    }
    
    // 终止
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("speechSynthesizer didCancel")
    }
}
