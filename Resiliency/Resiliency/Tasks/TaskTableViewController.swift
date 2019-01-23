//
//  TaskTableViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/21/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class TaskTableViewController: UIViewController {

    
    @IBOutlet var topBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var group : Group?
    var groups: [Group]?
    var tasks = [Hw]()
    var selectedFeed : PFObject?
    
    // MARK: - pull down to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getTasks()
        refreshControl.endRefreshing()
    }

    override func viewDidLoad() {
        if (!(PFUser.current()!.value(forKey: "coach") as! Bool)) {
            topBar.rightBarButtonItem = nil
        }
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.addSubview(self.refreshControl)
        self.getTasks()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.getTasks()
    }
    
    // MARK: - get tasks from the database
    func getTasks() {
        let query = Group.query(teamName: (group?.teamName)!)
        query?.findObjectsInBackground { (objects, error) in
            
            if let objects = objects as? [Group]{
                self.groups = objects
                self.tableView.reloadData()
            }
        }
    }
    
    
    @IBAction func gobackButton(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    
    @IBAction func touchAddButton(_ sender: Any) {
        performSegue(withIdentifier: "newAssignment", sender: self)
    }
    
    
    // MARK: - prepare for new assignment and comment sepeartly
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newAssignment" {
            let dest = segue.destination as! NewAssignmentViewController
            dest.group = group
        }
        if segue.identifier == "taskCommentSegue" {
            let dest = segue.destination as! taskCommentsViewController
            if let slctedFeed = selectedFeed {
                dest.selectedPost = slctedFeed
            }
        }
    }
}



extension TaskTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?[0].homeworkPointers.count ?? 0
    }
    
    // MARK: - set cell for image cell and text-only cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let messageObj = groups?[0].homeworkPointers[indexPath.row]
        let message = messageObj?.desc ?? ""
        let post_type = messageObj?.type ?? ""
        let post_time = messageObj?.time ?? ""
        let num_cmt = messageObj?.comments ?? 0
        let num_likes = (messageObj?.likes ?? [String]()).count

        if let imageFile = messageObj?.image {
            // MARK: - image cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImagePostTableViewCell
            (imageFile ).getDataInBackground { (data: Data?, error: Error?) in
                if error == nil {
                    let sender = messageObj?.sender
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
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell

        }
            // MARK: - text-only cell
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextPostTableViewCell
            let sender = messageObj?.sender
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
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell

        }
    }
    
    @objc func likeClicked(sender: UIButton) {
        let messageObj = groups?[0].homeworkPointers[sender.tag]
        let currentUserName = PFUser.current()?.username!
        let likesArray = messageObj?.likes ?? [String]()
        if likesArray.contains(currentUserName!) {
            return
        }
        messageObj?.addUniqueObject(currentUserName!, forKey: "likes")
        messageObj?.saveInBackground{(succeed, error) in
            self.tableView.reloadData()
        }
    }
    
    @objc func commentClicked(sender: UIButton) {
        selectedFeed = groups?[0].homeworkPointers[sender.tag]
        performSegue(withIdentifier: "taskCommentSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // MARK: - left swipe to delete from parse database
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if (!(PFUser.current()!.value(forKey: "coach") as! Bool)) {
                Helper.shared.showOKAlert(title: "Error", message: "you can not delete assignment since you are not a coach", viewController: self)
            }
            else {
                groups?[0].homeworkPointers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                let query = Group.query(teamName: (group?.teamName)!)
                query?.findObjectsInBackground { (objects, error) in
                    if let objects = objects as? [Group]{
                        objects[0].homeworkPointers = (self.groups?[0].homeworkPointers)!
                        objects[0].saveInBackground()
                    }
                }
            }
        }
    }
}
