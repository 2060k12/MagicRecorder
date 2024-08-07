//
//  Recording.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 7/8/2024.
//

import Foundation
import RealmSwift

class Recording : Object {
    var name : String
    var savedPath : URL
    
    init(name: String, savedPath: URL) {
        self.name = name
        self.savedPath = savedPath
    }
}
