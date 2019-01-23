//
//  GroupTableViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/21/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class GroupTableViewController: UITableViewController {
    
    var groupArray = [Group]()
    var selectedGroup : Group?
    
    @IBOutlet var topBar: UINavigationItem!
    
    // MARK: - pull down to refresh
    lazy var refreshControlForGroup: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getGroups()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        if (!(PFUser.current()!.value(forKey: "coach") as! Bool)) {
            topBar.rightBarButtonItem = nil
        }
        super.viewDidLoad()
        self.getGroups()
        tableView.addSubview(self.refreshControlForGroup)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getGroups()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = groupArray[indexPath.row]["teamName"] as? String
        return cell
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGroup = self.groupArray[indexPath.row]
        performSegue(withIdentifier: "groupSegue", sender: self)
    }
    
    // MARK: - prepare for tab view it needs to sepearte further
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let dest = destinationNavigationController.topViewController as! TaskMemberTabBarViewController
            if let selectedGroup = selectedGroup {
                dest.group = selectedGroup
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //delete group in the database
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if (!(PFUser.current()!.value(forKey: "coach") as! Bool)) {
                Helper.shared.showOKAlert(title: "Error", message: "you can not delete group since you are not a coach", viewController: self)
            }
            else {
                let query = PFQuery(className: "Group")
                query.whereKey("teamName", equalTo: groupArray[indexPath.row]["teamName"])
                query.findObjectsInBackground { (objects, error) in
                    if let objects = objects as! [Group]?{
                        objects[0].deleteInBackground()
                        self.groupArray.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    }
                }
            }
        }
    }
    
    // MARK: - get group of which the current user is a member
    func getGroups() {
        let query = PFQuery(className: "Group")
        query.whereKey("members", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects as! [Group]?{
                self.groupArray = objects
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }

}
