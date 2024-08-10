//
//  ProfileRepository.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class ProfileRepository {
    let db = Firestore.firestore()
    let fBStorage = Storage.storage()
    

    

    
    
    // get currentUser
    var currentUSer = Auth.auth().currentUser?.email

    
    func getCurrentUserProfileInfo() async -> Profile? {
        do {
            
            guard let currentUser = currentUSer else {
                print("Please login or check your internet connection.")
                return nil
            }
            
            
            let snapshot = try await db.collection("Users")
                .document(currentUser)
                .getDocument()
            
            if let data = snapshot.data() {
                return Profile(dictionary: data)
            } else {
                return nil
            }
        } catch {
            print("Can't get current user info \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    func addRecordingToCloud(recording : Recording, callback : @escaping (Result<Void, Error>) -> Void) {
  

        
        
        guard let recordingName = recording.name,
        let recordingUrl = recording.savedPath else {
            print("Data not complete, Please Check everything before trying again")
            callback(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Incomplete recording data"])))
            return
        }
        
           
            
            guard let currentUser = currentUSer else {
                print("Please Check your internet connection or Login before continuing")
                return
            }
        
            
            let storageRef = fBStorage.reference()
            let recRef = storageRef.child("\(currentUser)/\(recording.id)")
        
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let audioUrl = documentsURL.appendingPathComponent(recording.name, conformingTo: .wav)
            
    
            let uploadTask = recRef.putFile(from: audioUrl){ metadata, error in
        
            recRef.downloadURL { url, error in
                guard let downloadUrl = url else {
                    
                    
                    print("Can't fetch download Url")
                    return
                    
                }
                
                // dictionary that will hold the recording details
                let recordingDictionary :[String: Any] = [
                    "recordingName" : recording.name!,
                    "recordingUrl" : downloadUrl.absoluteString,
                    "dateTime" : Timestamp()
                ]
                
                self.db.collection("Users")
                   .document(currentUser)
                   .collection("Recording")
                   .document(recording.id)
                   .setData(recordingDictionary) {
                       error in
                       if let error = error {
                           print ("There is an error uploading your recording to the cloud, Try again later.")
                           callback(.failure(error))
                       }
                       else {
                           print("Successfully added to the cloud")
                           callback(.success(()))
                           
                       }
                   }
            }
            
        }
        
             
                
          
        
    }
    
    func removeFromTheCloud(recording : Recording, callback : @escaping(Result<Void, Error>) -> Void ){
        guard let currentUSer = currentUSer else {
            print("Please Check your internet connection or Login before continuing")
            return
        }
        
        db.collection("Users")
            .document(currentUSer)
           .collection("Recording")
           .document(recording.id)
           .delete(){
               error in
               
               if let error = error {
                   print ("There is an error deleting your recording to the cloud, Try again later.")
                   callback(.failure(error))
                   
               }
               else {
                   print("Successfully removed From  the cloud")
                   callback(.success(()))
                   
               }
           }
        
        
    }
    
    func getAllRecordings() async throws -> [Recording] {
        guard let currentUser = currentUSer else {
            print("Please login or check your internet connection")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in or no internet connection"])
        }
        
        let db = Firestore.firestore()
        
        // Fetch documents from Firestore
        let snapshot = try await db.collection("Users")
            .document(currentUser.lowercased())
            .collection("Recording")
            .getDocuments()
        
        // Process documents
        let recordings = snapshot.documents.compactMap { doc in
            let data = doc.data()
            return Recording(dictionary: data, id: doc.documentID)
        }
        
        return recordings
    }


    func checkIfInTheCloud(recording: Recording, callback : @escaping (Bool) -> Void) {
        guard let currentUser = currentUSer else {
            print("Please login or check your internet connection")
            return
        }
        
        db.collection("Users")
            .document(currentUser)
            .collection("Recording")
            .document(recording.id)
            .getDocument { snapshot, error in
                if let error = error  {
                    callback (false)
                    print("Something is off \(error.localizedDescription)" )
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    print("Not in the db" )
                    callback(false)
                    return
                }
                
                callback(true)
                
            }
        
    }
    
    
    
}
