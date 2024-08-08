//
//  Repository.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 7/8/2024.
//

import Foundation
import RealmSwift


class OfflineRepository {
    
    
    let realm = try! Realm()
   
    // this function will be used for development purpose only
    func getPathOfRealmDB() {
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
    // get all recordings from the database
    func getAllRecordings() -> Results<Recording>{
        let recordings = realm.objects(Recording.self)
        return recordings
    }
    
    
    // insert recording to the database
    func insertRecording(recording: Recording) {
        try! realm.write{
            realm.add(recording)
        }
    }
    
    
    // remove recording from the database
    func removeRecording(recording : Recording) {
        try! realm.write{
            realm.delete(recording)
        }
    }
    
}
