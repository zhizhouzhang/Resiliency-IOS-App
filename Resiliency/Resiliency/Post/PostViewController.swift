//
//  PostViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/10/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse

// MARK: - the outlook of a button
// https://stackoverflow.com/a/48470255/10592531
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var imageButton: UIButton!
    
    var postImg: UIImage?
    
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
    
    var type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.becomeFirstResponder()
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = borderColor.cgColor
        messageTextView.layer.cornerRadius = 5.0
        imageButton.borderWidth = 0.2
        imageButton.cornerRadius = 0.1 * imageButton.frame.height
        imageButton.borderColor = UIColor.lightGray
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    // MARK: - actually save the post
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "postSegue" {
            if messageTextView.text.count == 0 {
                Helper.shared.showOKAlert(title: "Required", message: "Please type something to post!", viewController: self)
                return
            }
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let year = components.year!
            let year_str = "\(year)"
            let month = components.month!
            var month_str = "\(month)"
            if month < 10 {
                month_str = "0" + month_str
            }
            let day = components.day!
            var day_str = "\(day)"
            if day < 10 {
                day_str = "0" + day_str
            }
            let hour = components.hour!
            var hour_str = "\(hour)"
            if hour < 10 {
                hour_str = "0" + hour_str
            }
            let minute = components.minute!
            var minute_str = "\(minute)"
            if minute < 10 {
                minute_str = "0" + minute_str
            }
            let second = components.second!
            // let curtime = "\(year)-\(month)-\(day) \(hour):\(minute)"
            let curtime = year_str + "-" + month_str + "-" + day_str + " " + hour_str + ":" + minute_str
            let imageName = "Image\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)"
            
            let messageObj = PFObject(className: "Messages")
            
            messageObj["sender"] = PFUser.current()
            messageObj["type"] = self.type
            messageObj["time"] = curtime
            messageObj["message"] = messageTextView.text
            messageObj["likes"] = [String]()
            messageObj["comments"] = 0
            // check existence of image
            if let image = self.postImg {
                let imgData = image.jpegData(compressionQuality: 0.8)
                let imgFile = PFFile(name: imageName, data: imgData!)
                messageObj["image"] = imgFile
            }
            
            messageObj.saveInBackground { (success, error) in
                self.messageTextView.text = ""
                if (success) {
                    Helper.shared.showOKAlert(title: "Posted", message: "Posted successfully!", viewController: self)
                } else {
                    let localized = (error?.localizedDescription)!
                    print(localized)
                }
            }
        }
    }

}
