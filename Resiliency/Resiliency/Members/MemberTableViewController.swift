//
//  MemberTableViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/21/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class MemberTableViewController: UITableViewController {
    
    @IBOutlet var topBar: UINavigationItem!
    //group is for input and groups is for the query reuslt
    var group : Group?
    var groups: [Group]?

    
    override func viewDidLoad() {
        if (!(PFUser.current()!.value(forKey: "coach") as! Bool)) {
            topBar.rightBarButtonItem = nil
        }
        super.viewDidLoad()
        self.getMembers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.getMembers()
    }
    
    
    @IBAction func goBackButton(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToVC12", sender: self)
    }
    
    // MARK: - set the cell name and image
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        let profile = groups?[0].members[indexPath.row].object(forKey: "avatar") as? PFFile
        profile?.getDataInBackground(block: { (data, error) in
            if error == nil {
                if let imageData = data {
                    cell.nameLabel?.text = self.groups?[0].members[indexPath.row]["username"] as? String
                    cell.avater.layer.cornerRadius = cell.avater.frame.size.width / 2
                    cell.avater.clipsToBounds = true
                    cell.avater.image = UIImage(data: imageData)
                }
            }
        })

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    
    // MARK: - query for pufusre pointer in group entity
    func getMembers() {
        let query = Group.query(teamName: (group?.teamName)!)
        query?.findObjectsInBackground { (objects, error) in
            if let objects = objects as? [Group]{
                self.groups = objects
                self.tableView.reloadData()
            }
        }
    }

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?[0].members.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    @IBAction func touchAdd(_ sender: Any) {
        performSegue(withIdentifier: "newMember", sender: self)
    }
    
    
    // MARK: - prepare for the goup varable in AddNewUserTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newMember" {
            let dest = segue.destination as! AddNewUserTableViewController
            dest.group = group
            for i in (groups?[0].members)! {
                dest.userNameArray.append(i.username)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @IBAction func unwindToMemberTable(segue:UIStoryboardSegue) { }
    
    // MARK: - Delete a memeber from a group and send notification
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if (!(PFUser.current()!.value(forKey: "coach") as! Bool)) {
                Helper.shared.showOKAlert(title: "Error", message: "you can not delete members since you are not a coach", viewController: self)
            }
            else {
                if groups?[0].members[indexPath.row].username == PFUser.current()?.username {
                    Helper.shared.showOKAlert(title: "Error", message: "you can not delete yourself", viewController: self)
                }
                else {
                    // MARK: - Send notification when removing a person from a group
                    let groupName = groups?[0].teamName
                    let data = [
                        "alert": "Your are removed from group \"" + groupName! + "\" by your coach."
                    ]
                    let push = PFPush()
                    push.setChannel(groups?[0].members[indexPath.row].username)
                    push.setData(data)
                    push.sendInBackground()
                    groups?[0].members.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    // delete the member from this group in parse database
                    let query = Group.query(teamName: (group?.teamName)!)
                    query?.findObjectsInBackground { (objects, error) in
                        if let objects = objects as? [Group]{
                            objects[0].members = (self.groups?[0].members)!
                            objects[0].saveInBackground()
                        }
                    }
                }
            }
        }
    }
    

}
