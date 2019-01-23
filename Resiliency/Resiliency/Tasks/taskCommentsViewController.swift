//
//  taskCommentsViewController.swift
//  Resiliency
//
//  Created by DeyangWang on 12/1/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class taskCommentsViewController: UIViewController {
    
    @IBOutlet weak var commentBox: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedPost: PFObject?
    var commentsArray = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        self.getComments()
    }
    
    // MARK: - fetch comments from database
    func getComments() {
        let query = PFQuery(className: "CommentsAssignment")
        query.whereKey("parent", equalTo: selectedPost!)
        query.findObjectsInBackground { (cand_comments: [PFObject]?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let comments = cand_comments {
                    self.commentsArray = comments
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - where actually comment action happening
    @IBAction func comment(_ sender: Any) {
        guard let commentText = commentBox.text else {
            Helper.shared.showOKAlert(title: "Empty Comment", message: "Please type something to comment", viewController: self)
            return
        }
        if commentText.isEmpty {
            Helper.shared.showOKAlert(title: "Empty Comment", message: "Please type something to comment", viewController: self)
            return
        }
        let commentObj = PFObject(className: "CommentsAssignment")
        commentObj["parent"] = self.selectedPost!
        commentObj["sender"] = PFUser.current()
        commentObj["content"] = commentText
        commentObj.saveInBackground { (success: Bool, error: Error?) in
            if success {
                self.commentBox.text = ""
                self.selectedPost?.incrementKey("comments")
                self.selectedPost?.saveInBackground(block: { (success: Bool, error: Error?) in
                    if !success {
                        Helper.shared.showOKAlert(title: "Error Happened", message: "Please try again", viewController: self)
                    } else {
                        self.getComments()
                        print("comment success")
                    }
                })
            } else {
                Helper.shared.showOKAlert(title: "Comment Error", message: "Please try again", viewController: self)
            }
        }
    }
    
    
}

// MARK: - comment table view setting
extension taskCommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let person = commentsArray[indexPath.row]["sender"] as! PFObject
        person.fetchIfNeededInBackground { (person: PFObject?, error: Error?) in
            if error == nil {
                let imageFile = person?.object(forKey: "avatar") as? PFFile
                imageFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                    if error == nil {
                        if let imageData = data {
                            cell.textLabel?.text = person!["username"] as? String
                            cell.imageView!.layer.cornerRadius = cell.imageView!.frame.size.width / 2
                            cell.imageView!.clipsToBounds = true
                            cell.imageView?.image = UIImage(data: imageData)
                            cell.detailTextLabel?.text = self.commentsArray[indexPath.row]["content"] as? String
                            cell.detailTextLabel?.numberOfLines = 0
                        }
                    }
                })
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

