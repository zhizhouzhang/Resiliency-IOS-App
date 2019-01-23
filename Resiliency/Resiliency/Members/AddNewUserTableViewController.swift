//
//  AddNewUserTableViewController.swift
//  Resiliency
//
//  Created by DeyangWang on 11/24/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class AddNewUserTableViewController: UITableViewController {
    
    var group : Group?
    var userArray = [PFUser]()
    var userNameArray : [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUsers()
    }

    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    // MARK: - set the cell: core feature if the user is added then you can not add it again the button will be disabled
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let profile = userArray[indexPath.row].object(forKey: "avatar") as? PFFile
        profile?.getDataInBackground(block: { (data, error) in
            if error == nil {
                if let avatarData = data {
                    cell.nameLabel?.text = self.userArray[indexPath.row]["username"] as? String
                    cell.avater.layer.cornerRadius = cell.avater.frame.size.width / 2
                    cell.avater.clipsToBounds = true
                    cell.avater.image = UIImage(data: avatarData)
                }
            }
        })

        
        if (userNameArray.contains(userArray[indexPath.row].username)) {
            cell.addButton.setTitle("Added", for: UIControl.State.normal)
            cell.addButton.isEnabled = false
        }
        else {
            cell.addButton.isEnabled = true
            cell.addButton.setTitle("ADD", for:  UIControl.State.normal)
        }
        
        // tag for different button
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(inviteClicked(sender:)), for: .touchUpInside)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    // MARK: - Invite new member to the group and send notification

    @objc func inviteClicked(sender: UIButton) {
        let user = userArray[sender.tag]
        let groupName = group?.teamName
        group?.add(user, forKey: "members")
        group?.saveInBackground(block: {(succeed, error) in
            if !succeed {
                Helper.shared.showOKAlert(title: "Error", message: "Invite Failed", viewController: self)
            }
            else {
                // MARK: - Send notification when inviting a person to a group
                let data = [
                    "alert": "Your are invited to group \"" + groupName! + "\"."
                    ]
                let push = PFPush()
                push.setChannel(user.username)
                push.setData(data)
                push.sendInBackground()
                
                self.performSegue(withIdentifier: "unwindToMemberTable", sender: self)
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    // MARK: - get new users
    func getUsers() {
        let query = PFQuery(className: "_User")
        
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects as! [PFUser]?{
                self.userArray = objects
                self.tableView.reloadData()
            }
        }
    }

}
