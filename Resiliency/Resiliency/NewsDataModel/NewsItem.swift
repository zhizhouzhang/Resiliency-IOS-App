//
//  NewsItem.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 12/2/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse
// https://www.raywenderlich.com/584-push-notifications-tutorial-getting-started
final class NewsItem: NSObject {
    let title: String
    let date: Date
    
    init(title: String, date: Date) {
        self.title = title
        self.date = date
    }
    
    class func makeNewsItem(_ notificationDictionary: [String: AnyObject]) -> NewsItem? {
        if let news = notificationDictionary["alert"] as? String {
            let date = Date()
            // get groupName
            let separated = news.components(separatedBy: "\"")
            let groupName = separated.dropFirst().first
            
            if news.range(of: "invited") != nil {
                // add group name to channels
                if let installation = PFInstallation.current() {
                    installation.addUniqueObject(groupName!, forKey: "channels")
                    installation.saveInBackground()
                }
            }
            
            if news.range(of: "removed") != nil {
                // remove group name from channels
                if let installation = PFInstallation.current() {
                    installation.remove(groupName!, forKey: "channels")
                    installation.saveInBackground()
                }
            }
           
            let newsItem = NewsItem(title: news, date: date)
            let newsStore = NewsStore.shared
            newsStore.add(item: newsItem)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: NewsFeedTableViewController.RefreshNewsFeedNotification), object: self)
            return newsItem
        }
        return nil
    }
}
