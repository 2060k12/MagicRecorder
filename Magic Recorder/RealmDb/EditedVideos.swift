//
//  EditedVideos.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 10/8/2024.
//

import Foundation
import RealmSwift

class EditedVideos: Object {
    
    @objc var id = UUID().uuidString
    @objc var videoName : String?
    @objc var videosPath : String?
    @objc var date : Date?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(videoName: String?, videosPath: String?, date: Date){
        self.init()
        self.videoName = videoName
        self.videosPath = videosPath
        self.date = date
    }
    
}
