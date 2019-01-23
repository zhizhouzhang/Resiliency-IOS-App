//
//  TaskMemberTabBarViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/21/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class TaskMemberTabBarViewController: UITabBarController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    var group : Group?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedViewController = self.viewControllers![0]
        
        // MARK: - set group variable in different tabs
        let nav1 = self.viewControllers![0] as! UINavigationController
        let tab1 = nav1.topViewController as! TaskTableViewController
        tab1.group = group
        
        let nav2 = self.viewControllers![1] as! UINavigationController
        let tab2 = nav2.topViewController as! MemberTableViewController
        tab2.group = group

    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
