//
//  NewsStore.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 12/2/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
// https://www.raywenderlich.com/584-push-notifications-tutorial-getting-started
class NewsStore: NSObject {
    // singleton to store an array of NewsItem
    static let shared = NewsStore()
    
    var items: [NewsItem] = []

    func add(item: NewsItem) {
        items.insert(item, at: 0)
    }
}
