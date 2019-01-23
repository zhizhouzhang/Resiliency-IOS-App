//
//  PostModel.swift
//  Resiliency
//
//  Created by admin on 11/23/18.
//  Copyright © 2018 admin. All rights reserved.
//

import Foundation
import UIKit

struct Post {
    var time: String
    var type: String
    var text: String
    var image: UIImage?
}

struct Comment {
    var username: String
    var conetent: String
}
