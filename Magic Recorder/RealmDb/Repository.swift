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
   
    
    // MARK: - Recordings

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
    
    // MARK: - Videos
    
    
      // For Videos
      func getAllVideos() -> Results<EditedVideos> {
          return realm.objects(EditedVideos.self)
      }
      
      func insertVideo(video: EditedVideos) {
          do {
              try realm.write {
                  realm.add(video)
              }
          } catch {
              print("Error inserting video: \(error.localizedDescription)")
          }
      }
      
      func removeVideo(video: EditedVideos) {
          do {
              try realm.write {
                  realm.delete(video)
              }
          } catch {
              print("Error removing video: \(error.localizedDescription)")
          }
      }
    
    
    
    // MARK: - Dev Only Functions (Testing Purpose)

    
//    func getPathOfRealmDB() {
//    // print(Realm.Configuration.defaultConfiguration.fileURL)
//    }

    
}
