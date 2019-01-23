//
//  AddGroupViewController.swift
//  Resiliency
//
//  Created by DeyangWang on 12/5/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class AddGroupViewController: UIViewController {
    
    @IBOutlet weak var inputGroupName: UITextField!
    var groupArray = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getGroups()

    }
    
    
    // MARK: - add the group and some error checking
    @IBAction func touchAddButton(_ sender: Any) {
        var repeatGroup = false
        let input = inputGroupName.text
        for i in groupArray {
            if input == i.teamName {
                repeatGroup = true
                break
            }
        }
        if input == "" {
            Helper.shared.showOKAlert(title: "Error", message: "there must be a proper name for group ", viewController: self)
        }
        
        if repeatGroup {
        Helper.shared.showOKAlert(title: "Error", message: "there has alreay existed same name in group list", viewController: self)
        }
        else {
            let groupObj = Group()
            
            groupObj.creator = PFUser.current()?.username
            groupObj.teamName = input
            groupObj.homeworkPointers = []
            groupObj.members = [PFUser.current()] as! [PFUser]
            
            groupObj.saveInBackground { (succeed, error) in
                if succeed {
                }
                else {
                    print(error!)
                }
            }
            
            
            performSegue(withIdentifier: "unwindToGroupList", sender: self)
            
        }
    }
    
    // MARK: - get group to determine if this group is existing already
    func getGroups() {
        let query = PFQuery(className: "Group")
        query.whereKey("members", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects as! [Group]?{
                self.groupArray = objects
            }
        }
    }


}
