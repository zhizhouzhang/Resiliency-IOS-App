//
//  CheckinTableViewController.swift
//  Resiliency
//
//  Created by admin on 11/14/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class CheckinTableViewController: UITableViewController {
    
    var checkinArray: [String] = ["Workout", "Positive Thoughts"]
    var slctType: String!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkinCell", for: indexPath)
        let icon = UIImage(named: checkinArray[indexPath.row])
        let box = CGRect(x: 0, y: 0, width: 50, height: 50)
        UIGraphicsBeginImageContext(box.size)
        icon?.draw(in: box)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        cell.imageView?.image = image
        
        cell.textLabel?.text = checkinArray[indexPath.row]
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkinArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.slctType = self.checkinArray[indexPath.row]
        performSegue(withIdentifier: "checkinSegue", sender: self)
    }


    
    // MARK: - Navigation

    // MARK: - prepare for the forum page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        if segue.identifier == "checkinSegue" {
            let postVC = segue.destination.children.first as! PostViewController
            postVC.type = self.slctType
        }
    }
    

}
