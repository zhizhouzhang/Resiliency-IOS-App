//
//  AppDelegate.swift
//  Resiliency
//
//  Created by admin on 11/5/18.
//  Copyright © 2018 admin. All rights reserved.
//We reference this https://www.udemy.com/parse-server-development/ Udemy course for some basic code snippet

import UIKit
import Parse
import IQKeyboardManagerSwift
import UserNotifications

// https://www.raywenderlich.com/584-push-notifications-tutorial-getting-started
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "4wd1MiwjtuksUKUGXaVVXjbxvBc8Rs3iT36e4aVm"
            $0.clientKey = "MgJZIqWfpVm3XY15EO8TnvYnpDfVWEISCKlVmSkP"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: parseConfig)
        // MARK: - check if the user is currently logged in
        var vc: UIViewController!
        if PFUser.current() == nil {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            vc = storyboard.instantiateViewController(withIdentifier: "login")
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            vc = storyboard.instantiateViewController(withIdentifier: "home")
        }
        window?.rootViewController = vc
        
        // register for push notification
        registerForPushNotifications()
        // clear notification badge number to 0 when launching
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        // MARK: - App wasn’t running and the user launches it by tapping the push notifications
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            // transfer notificatio to a new NewsItem
            _ = NewsItem.makeNewsItem(notification)
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 4
        }
        // If NOT launched from notification
        else {
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        
        return true
    }
    
    // MARK: - Register for push notification
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    // MARK: - If user decline the permission for notification
    // user can, at any time, go into the Settings app and change the notification permissions
    // we need to get the settings again when launching the app
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            }) 
        }
    }
    
    // MARK: - App was running either in the foreground, or the background
    // receive notification, show it on News Tab
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        _ = NewsItem.makeNewsItem(aps)
        (window?.rootViewController as? UITabBarController)?.selectedIndex = 4
    }

    
    // MARK: - Inform result of registerForRemoteNotifications
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Uncomment the following to print current device token on Xcode console
        /*let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        */
        
        // Store the deviceToken in the current Installation and save it to Parse
        if let installation = PFInstallation.current() {
            installation.setDeviceTokenFrom(deviceToken)
            installation.saveInBackground()
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
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

