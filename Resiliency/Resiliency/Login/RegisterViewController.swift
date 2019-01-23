//
//  RegisterViewController.swift
//  Resiliency
//
//  Created by admin on 11/14/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameBar: UITextField!
    @IBOutlet weak var passwordBar: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkButton.setImage(UIImage(named:"Checkmarkempty"), for: .normal)
        checkButton.setImage(UIImage(named:"Checkmark"), for: .selected)
    }
    
    // MARK: - stor user in the database
    @IBAction func register(_ sender: Any) {
        guard let username = usernameBar.text, let password = passwordBar.text else {
            return
        }
        let user = PFUser()
        user.username = username.lowercased()
        user.password = password
        
        //new attribute of a user
        if checkButton.state == .normal {
            user["coach"] = false
        }
        else {
            user["coach"] = true
        }
        let image = UIImage(named: "robert_avatar")
        let imageData = image?.jpegData(compressionQuality: 0.8)
        let imageFile = PFFile(name: username, data: imageData!)
        user["avatar"] = imageFile

        
        user.signUpInBackground { (succeed, error) in
            if !succeed {
                let localized = (error?.localizedDescription)!
                Helper.shared.showOKAlert(title: "Error", message: localized, viewController: self)
            } else {
                Helper.shared.switchStoryboard(storyboardName: "Main", identifier: "home")
            }
        }
    }
    
    // MARK: - code snippet from https://www.iostutorialjunction.com/2018/01/create-checkbox-in-swift-ios-sdk-tutorial-for-beginners.html
    @IBAction func tapCheckButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }) { (success) in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: nil)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
