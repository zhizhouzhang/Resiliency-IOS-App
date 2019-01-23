//
//  PostsTableViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/11/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class PostsTableViewController: UIViewController {
    

    
    @IBOutlet weak var tableView: UITableView!
    var messages = [PFObject]()
    var selectedFeed : PFObject?
    
    // MARK: - pull dwon to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getMessages()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.addSubview(self.refreshControl)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessages()
    }
    
    // MARK: - query getMessage
    func getMessages() {
        let query = PFQuery(className: "Messages")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects {
                self.messages = objects
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - prepare for the comment view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentSegue" {
            let dest = segue.destination as! CommentsViewController
            if let slctedFeed = selectedFeed {
                dest.selectedPost = slctedFeed
            }
        }
    }
    
    @IBAction func postFromPostVC(_ sender: UIStoryboardSegue) {
        getMessages()
    }
    
    @IBAction func cancelFromPostVC(_ sender: UIStoryboardSegue) {
    }
}

// MARK: - actually show the post
extension PostsTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageObj = messages[indexPath.row]
        let message = messageObj["message"] as? String ?? ""
        let post_type = messageObj["type"] as? String ?? ""
        let post_time = messageObj["time"] as? String ?? ""
        let num_cmt = messageObj["comments"] as? UInt64 ?? 0
        let num_likes = (messageObj["likes"] as? [String] ?? [String]()).count
        // MARK: - image cell
        if let imageFile = messageObj.object(forKey: "image") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImagePostTableViewCell
            (imageFile as! PFFile).getDataInBackground { (data: Data?, error: Error?) in
                if error == nil {
                    let sender = messageObj["sender"] as? PFUser
                    sender?.fetchIfNeededInBackground(block: { (sender: PFObject?, error: Error?) in
                        if error == nil {
                            cell.usernameLabel.text = sender!["username"] as? String
                            let avatarFile = sender?.object(forKey: "avatar") as? PFFile
                            avatarFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                                if error == nil {
                                    if let avatarData = data {
                                        cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
                                        cell.avatar.clipsToBounds = true
                                        cell.avatar.image = UIImage(data: avatarData)
                                    }
                                }
                            })
                            cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
                            cell.avatar.clipsToBounds = true
                            // cell.avatar.image = UIImage(data: avatarData!)
                            cell.imageContent.image = UIImage(data: data!)
                            cell.typeLabel.text = post_type
                            cell.timeLabel.text = post_time
                            cell.content.text = message
                            
                            cell.commentButton.setTitle("\(num_cmt) comments", for: .normal)
                            cell.likeButton.setTitle("\(num_likes) likes", for: .normal)
                            
                            cell.likeButton.tag = indexPath.row
                            cell.likeButton.addTarget(self, action: #selector(self.likeClicked(sender:)), for: .touchUpInside)
                            
                            cell.commentButton.tag = indexPath.row
                            cell.commentButton.addTarget(self, action: #selector(self.commentClicked(sender:)) , for: .touchUpInside)
                        }
                    })
                }
            }
            return cell
            // MARK: - text cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextPostTableViewCell
            let sender = messageObj["sender"] as? PFUser
            sender?.fetchIfNeededInBackground(block: { (sender: PFObject?, error: Error?) in
                if error == nil {
                    cell.usernameLabel?.text = sender!["username"] as? String
                    let avatarFile = sender?.object(forKey: "avatar") as? PFFile
                    avatarFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                        if error == nil {
                            if let avatarData = data {
                                // print("text avatar")
                                cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
                                cell.avatar.clipsToBounds = true
                                cell.avatar.image = UIImage(data: avatarData)
                            }
                        }
                    })
                    cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
                    cell.avatar.clipsToBounds = true
                    cell.typeLabel.text = post_type
                    cell.timeLabel.text = post_time
                    cell.content.text = message
                    
                    cell.commentButton.setTitle("\(num_cmt) comments", for: .normal)
                    cell.likeButton.setTitle("\(num_likes) likes", for: .normal)
                    
                    cell.likeButton.tag = indexPath.row
                    cell.likeButton.addTarget(self, action: #selector(self.likeClicked(sender:)), for: .touchUpInside)
                    
                    cell.commentButton.tag = indexPath.row
                    cell.commentButton.addTarget(self, action: #selector(self.commentClicked(sender:)) , for: .touchUpInside)
                }
            })
            return cell
        }
    }
    // MARK: - like feature
    @objc func likeClicked(sender: UIButton) {
        let messageObj = messages[sender.tag]
        let currentUserName = PFUser.current()?.username!
        let likesArray = messageObj["likes"] as? [String] ?? [String]()
        if likesArray.contains(currentUserName!) {
            return 
        }
        messageObj.addUniqueObject(currentUserName!, forKey: "likes")
        messageObj.saveInBackground{(succeed, error) in
            self.tableView.reloadData()
        }
    }
    // MARK: - comment feature
    @objc func commentClicked(sender: UIButton) {
        selectedFeed = messages[sender.tag]
        performSegue(withIdentifier: "commentSegue", sender: self)
    }
}
