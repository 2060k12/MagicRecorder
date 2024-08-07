//
//  Recording.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 7/8/2024.
//

import Foundation
import RealmSwift


class Recording : Object {
    @objc dynamic var id = UUID().uuidString // Generates Primary Key
    @objc dynamic var name : String!
    @objc dynamic var savedPath : String!
    convenience init(name: String, savedPath: String) {
        self.init()
        self.name = name
        self.savedPath = savedPath
    }
    
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
