//
//  AccountViewController.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/11/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Parse
// https://stackoverflow.com/a/29726675
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let genderArray = [String](arrayLiteral: "Male", "Female")
    let ageArray = [Int](0...100)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == agePicker {
            return ageArray.count
        } else {
            return genderArray.count
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == agePicker {
            return String(ageArray[row])
        } else {
            return genderArray[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == agePicker {
            age.text = String(ageArray[row])
        } else {
            gender.text = genderArray[row]
        }
    }
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var gender: UITextField!
    
    var cur_user: PFUser!
    var isEdit: Bool = false
    let agePicker = UIPickerView()
    let genderPicker = UIPickerView()
    // MARK: - set the gender and age
    override func viewDidLoad() {
        super.viewDidLoad()
        agePicker.delegate = self
        genderPicker.delegate = self
        self.age.inputView = agePicker
        self.gender.inputView = genderPicker
        self.navigationItem.leftBarButtonItem?.title = "Edit"
        self.cur_user = PFUser.current()!
        self.username.text = cur_user.username
        self.age.text = cur_user.object(forKey: "age") as? String
        self.gender.text = cur_user.object(forKey: "gender") as? String
        uploadButton.layer.cornerRadius = uploadButton.bounds.width / 2
        uploadButton.clipsToBounds = true
        let profile = PFUser.current()?.object(forKey: "avatar") as? PFFile
        profile?.getDataInBackground(block: { (data, error) in
            if error == nil {
                if let imageData = data {
                    if imageData.count == 0 {
                        self.uploadButton.setBackgroundImage(UIImage(named: "robert_avatar") , for: .normal)
                    } else {
                        self.uploadButton.setBackgroundImage(UIImage(data: imageData), for: .normal)
                    }
                }
            }
        })
        
    }
    
    // MARK: - edit button
    @IBAction func makeEditable(_ sender: Any) {
        if self.isEdit == false {
            self.age.isUserInteractionEnabled = true
            self.gender.isUserInteractionEnabled = true
            self.navigationItem.leftBarButtonItem?.title = "Save"
        } else {
            self.age.isUserInteractionEnabled = false
            self.gender.isUserInteractionEnabled = false
            saveButtonTapped()
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        }
        self.isEdit = !isEdit
    }
    
    // MARK: - save the setting
    func saveButtonTapped() {

        if let new_age = self.age.text, let new_gender = self.gender.text {
            self.cur_user.setObject(new_age, forKey: "age")
            self.cur_user.setObject(new_gender, forKey: "gender")
            self.cur_user.saveInBackground(block: { (succeed, error) in
                if error != nil {
                    let localized = (error?.localizedDescription)!
                    Helper.shared.showOKAlert(title: "Error", message: localized, viewController: self)
                } else {
                    print("Edit Acct Info!")
                }
            })
        }
        
    }
    
    // MARK: - logout the app
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to logout?", message: "", preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .default) { (action) in
            PFUser.logOut()
            Helper.shared.switchStoryboard(storyboardName: "Login", identifier: "login")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - user image set up
    @IBAction func uploadAvatar(_ sender: Any) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let box = CGRect(x: 0, y: 0, width: 200, height: 200)
        UIGraphicsBeginImageContextWithOptions(box.size, false, 1.0)
        image.draw(in: box)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        uploadButton.setBackgroundImage(newImage, for: .normal)
        let imageData = newImage?.jpegData(compressionQuality: 0.8)
        let imageFile = PFFile(name:PFUser.current()!.username, data:imageData!)
        PFUser.current()!["avatar"] = imageFile
        PFUser.current()?.saveInBackground(block: { (succeed, error) in
            if error != nil {
                let localized = (error?.localizedDescription)!
                Helper.shared.showOKAlert(title: "Error", message: localized, viewController: self)
            } else {
                print("Uploaded Avatar!")
            }
        })
        picker.dismiss(animated: true, completion: nil)
    }
    


}
