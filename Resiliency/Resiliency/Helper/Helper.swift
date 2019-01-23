//
//  Helper.swift
//  Resiliency
//
//  Created by Zhizhou Zhang on 11/10/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class Helper{
    // singleton
    static let shared = Helper()
    // switch story board
    func switchStoryboard(storyboardName: String, identifier: String) {
        let sboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = sboard.instantiateViewController(withIdentifier: identifier)
        let appDelegate = UIApplication.shared.delegate  as! AppDelegate
        
        appDelegate.window?.rootViewController = vc
    }
    // show OK alert
    func showOKAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil) )
        viewController.present(alert, animated: true)
        return
    }
}
