//
//  Group.swift
//  Resiliency
//
//  Created by DeyangWang on 11/23/18.
//  Copyright © 2018 admin. All rights reserved.
//

import Foundation
import Parse


// MARK: - class for the parse Group entity
class Group: PFObject, PFSubclassing {
    static func parseClassName() -> String {
        return "Group"
    }
    
    @NSManaged var creator: String?
    @NSManaged var teamName: String?
    @NSManaged var homeworkPointers : [Hw]
    @NSManaged var members : [PFUser]
    
    // MARK: - query for a specific name of the team because this query has been used a lot so we put it here in the class
    class func query(teamName: String) -> PFQuery<PFObject>? {
        
        let query = PFQuery(className: Group.parseClassName())
        query.whereKey("teamName", equalTo: teamName)
        query.includeKey("homeworkPointers")
        query.includeKey("members")
        query.whereKey("members", equalTo: PFUser.current()!)
       
        return query
    }
}

// MARK: - class for the parse HW entity which saved as a pointer in the Group
class Hw: PFObject, PFSubclassing {
    static func parseClassName() -> String {
        return  "Hw"
    }
    @NSManaged var sender: PFUser
    @NSManaged var type: String?
    @NSManaged var desc: String?
    @NSManaged var image: PFFile?
    @NSManaged var time : String?
    @NSManaged var likes : [String]
    @NSManaged var comments: Int
    
}
