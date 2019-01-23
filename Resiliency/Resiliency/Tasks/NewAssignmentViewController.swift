//
//  NewAssignmentViewController.swift
//  Resiliency
//
//  Created by DeyangWang on 11/24/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

class NewAssignmentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var typeField: UITextField!
    var postImg: UIImage?
    var group: Group?
    var type: String!
    
    // MARK: - camera feature
    @IBAction func openCamera(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera Unavailable")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - album feature
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let box = CGRect(x: 0, y: 0, width: 200, height: 200)
        UIGraphicsBeginImageContextWithOptions(box.size, false, 1.0)
        image.draw(in: box)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.imageButton.setBackgroundImage(newImage, for: .normal)
        self.postImg = newImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        typeField.placeholder = "Type of Training"
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

        submitButton.cornerRadius = 8
        submitButton.borderWidth = 0.2
        submitButton.layer.borderColor = borderColor.cgColor
        messageTextView.becomeFirstResponder()
        

        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = borderColor.cgColor
        messageTextView.layer.cornerRadius = 5.0
        imageButton.borderWidth = 0.2
        imageButton.cornerRadius = 0.1 * imageButton.frame.height
        imageButton.borderColor = UIColor.lightGray
    }
    
    // MARK: - actually post it
    @IBAction func postAction(_ sender: Any) {
        if messageTextView.text.count == 0 {
            Helper.shared.showOKAlert(title: "Required", message: "Please type something to post!", viewController: self)
            return
        }
        if typeField.text != nil {
            type = typeField.text!
        }
        else {
            type = "Assignment"
        }
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = components.year!
        let month = components.month!
        let day = components.day!
        let hour = components.hour!
        let minute = components.minute!
        let second = components.second!
        let curtime = "\(year)-\(month)-\(day) \(hour):\(minute)"
        let imageName = "Image\(year)-\(month)-\(day)_\(hour)_\(minute)_\(second).png"
        
        let hw = Hw()
        hw.sender = PFUser.current()!
        hw.type = self.type
        hw.time = curtime
        hw.desc = messageTextView.text
        hw.likes = [String]()
        hw.comments = 0
        if let image = self.postImg {
            let imgData = image.jpegData(compressionQuality: 0.8)
            let imgFile = PFFile(name: imageName, data: imgData!)
            hw.image = imgFile
        }
        
        hw.saveInBackground { (success, error) in
            self.messageTextView.text = ""
            if (success) {
                Helper.shared.showOKAlert(title: "Posted", message: "Posted successfully!", viewController: self)
            } else {
                let localized = (error?.localizedDescription)!
                print(localized)
            }
        }
        
        group?.add(hw, forKey: "homeworkPointers")
        group?.saveInBackground(block: {(succeed, error) in
            self.messageTextView.text = ""
            if succeed {
                Helper.shared.showOKAlert(title: "Posted", message: "Posted successfully!", viewController: self)
                
            }else {
                let localized = (error?.localizedDescription)!
                print(localized)
            }
        })
        
        // MARK: - Send notification to members in this group when posted a new task
        let groupName = group?.teamName
        let data = [
            "alert": "A new task posted in group \"" + groupName! + "\", check it out."
        ]
        let push = PFPush()
        push.setChannel(groupName!)
        push.setData(data)
        push.sendInBackground()
    }
}
