//
//  LoginViewController.swift
//  Resiliency
//
//  Created by admin on 11/14/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameBar: UITextField!
    @IBOutlet weak var passwordBar: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func login(_ sender: Any) {
        guard let username = usernameBar.text, let password = passwordBar.text else {
            print("check username or password")
            return
        }
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if error == nil {
                if let installation = PFInstallation.current() {
                    if let uname = PFUser.current()?.username {
                        installation.addUniqueObject(uname, forKey: "channels")
                        installation.saveInBackground()
                    }
                }
                Helper.shared.switchStoryboard(storyboardName: "Main", identifier: "home")
            } else {
                let localized = (error?.localizedDescription)!
                Helper.shared.showOKAlert(title: "Error", message: localized, viewController: self)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
