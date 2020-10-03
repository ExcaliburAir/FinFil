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
    // used by sidemenu for remenber
    var sideMenuInt: Int = SelectedSideMenu.search
    // audio use this
    fileprivate let avSpeech = AVSpeechSynthesizer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // setup notification center
        self.configUserNotification()
        // setup audio
        self.configAVSpeech()
        // setup the realm DB
        self.configRealm()
        // setup
        self.configureSideMenu()
        // setup the app
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
        // start to listening the network status
        NetworkAPI.startListenNetwork()
        
        // if app read the movie's overview or not. default is yes
        let soundType = UserDefaultBase().getSoundType()
        if soundType.isEmpty {
            UserDefaultBase().setSoundType(string: UserDefaultBase.soundOn)
        }
        
        // if make the network listening useable. default is yes
        let appType = UserDefaultBase().getAppType()
        if appType.isEmpty {
            UserDefaultBase().setAppType(string: UserDefaultBase.listeningNetwork)
        }
        
        // setup window's rootview to use side menu
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        weak var sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenu") as? SideMenuController
        self.window?.rootViewController = sideMenuViewController
    }
    
    private func configureSideMenu() {
        // the width of sidemenu
        SideMenuController.preferences.basic.menuWidth = 280
        // the first view id in sidemenu
        SideMenuController.preferences.basic.defaultCacheKey = "0"
        // the style of sidemnu that get out
        SideMenuController.preferences.basic.position = .sideBySide
    }
    
    // setup notification
    private func configUserNotification() {
        // let user allow to recive the notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { (granted, error) in
            print("Permission granted:\(granted)")
            guard granted else { return }
            
            // regist app to remote
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    // setup audio
    private func configAVSpeech() {
        avSpeech.delegate = self
    }
    
    // setup realm DB
    private func configRealm() {
        // DB's version
        let dbVersion: UInt64 = 1
        // get path of app
        let docPath = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
            )[0] as String
        // the path of DB
        let dbPath = docPath.appending("/defaultDB.realm")
        // DB's config
        let config = Realm.Configuration(
            fileURL: URL.init(string: dbPath),
            inMemoryIdentifier: nil,
            syncConfiguration: nil,
            encryptionKey: nil,
            readOnly: false,
            schemaVersion: dbVersion,
            // refresh DB object when version update
            migrationBlock: { (migration, oldSchemaVersion) in

        },
            deleteRealmIfMigrationNeeded: false,
            shouldCompactOnLaunch: nil,
            objectTypes: nil
        )
        // setup config
        Realm.Configuration.defaultConfiguration = config
        // if update success or not
        Realm.asyncOpen{ (realm, error) in
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
    
    // receive notification when app in background
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void)
    {
        // defulte settings
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("Default Action")
        }
        // disappare
        else if (response.actionIdentifier == UNNotificationDismissActionIdentifier) {
            print("Dismiss action")
        }
        // custom settings
        else if (response.notification.request.content.categoryIdentifier == "calendarCategory") {
            print("Dismiss action")
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
    }
    
    // receive notification when app is using
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // paramaters
        var options: UNNotificationPresentationOptions = []
        let identifier = notification.request.identifier
        
        // identifier of notification
        if identifier == "App_Network_Status" {
            // [.alert, .sound]
            options = [.alert]
        }

        completionHandler(options)
    }
}

// MARK:- AVSpeechSynthesis
extension AppDelegate {
    
    // play
    func startSpeek(text: String!) {
        // stop it first
        if avSpeech.isSpeaking {
            cancleSpeek()
        }
        
        // the text that want to read
        let utterance = AVSpeechUtterance(string: text)
        // speech speed
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        // language type
        utterance.voice = AVSpeechSynthesisVoice(language: Utils().getLanguageType(text))
        // the valume, [0-1] Default = 1
        utterance.volume = 1
        // the time between two speech, defult = 0.0
        utterance.postUtteranceDelay = 0.1
        // base line of speech, [0.5 - 2] Default = 1
        utterance.pitchMultiplier = 1
        
        if UserDefaultBase().getSoundType() == UserDefaultBase.soundOn {
            DispatchQueue.global().async {
                // speak
                self.avSpeech.speak(utterance)
            }
        }
    }
    
    // pause
    func pauseSpeek() {
        avSpeech.pauseSpeaking(at: .immediate)
    }
    
    // continue
    func continueSpeek() {
        avSpeech.continueSpeaking()
    }
    
    // stop
    func cancleSpeek() {
        avSpeech.stopSpeaking(at: .immediate)
    }
}

// MARK:- AVSpeechSynthesizerDelegate
extension AppDelegate: AVSpeechSynthesizerDelegate {
    
    // will play
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        // which part to read
        let subStr = utterance.speechString.dropFirst(characterRange.location).description
        let _ = subStr.dropLast(subStr.count - characterRange.length).description
    }
    
    // playing
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("speechSynthesizer didStart")
    }
    
    // did finish
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("speechSynthesizer didFinish")
    }
    
    // did pause
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("speechSynthesizer didPause")
    }
    
    // did continue
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("speechSynthesizer didContinue")
    }
    
    // did cancel
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("speechSynthesizer didCancel")
    }
}
