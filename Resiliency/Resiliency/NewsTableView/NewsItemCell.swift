//
//  NewsItemCell.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 12/2/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class NewsItemCell: UITableViewCell {
    // when a notification is received, a new NewsItem is created
    // show the info of the NewsItem on the NewsItem Table Cell
    func updateWithNewsItem(_ item:NewsItem) {
        self.textLabel?.text = item.title
        self.detailTextLabel?.text = DateParser.displayString(for: item.date)
    }
}
