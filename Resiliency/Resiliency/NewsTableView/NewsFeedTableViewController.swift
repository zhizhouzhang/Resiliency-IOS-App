//
//  NewsFeedTableViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 12/2/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

// https://www.raywenderlich.com/584-push-notifications-tutorial-getting-started
class NewsFeedTableViewController: UITableViewController {

    static let RefreshNewsFeedNotification = "RefreshNewsFeedNotification"
    // singleton NewsStore
    let newsStore = NewsStore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewsFeedTableViewController.receivedRefreshNewsFeedNotification(_:)), name: NSNotification.Name(rawValue: NewsFeedTableViewController.RefreshNewsFeedNotification), object: nil)
    }
    // receive refresh news feed notification
    @objc func receivedRefreshNewsFeedNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsStore.items.count
    }
    
    // show the info of each NewsItem Table Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemCell", for: indexPath) as! NewsItemCell
        // show the info of the NewsItem on the NewsItem Table Cell
        cell.textLabel?.numberOfLines = 2
        cell.updateWithNewsItem(newsStore.items[indexPath.row])
        return cell
    }
    
    // swipe left to delete a table cell
    // and delete this NewsItem from NewsStore
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        newsStore.items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
