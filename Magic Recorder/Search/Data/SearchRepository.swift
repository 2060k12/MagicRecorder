//
//  SearchRepository.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 15/8/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class SearchRepository{
    
    
    let db = Firestore.firestore()
    
    
    func searchUser(searchedText: String, completion: @escaping (Profile?) -> Void) {
        let docRef = db.collection("Users").document(searchedText)
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                guard let data = document.data() else {
                    print("Data is null")
                    completion(nil)
                    return
                }
                let profile = Profile(dictionary: data)
                completion(profile)
            } else {
                print("User not found with email \(searchedText)")
                completion(nil)
            }
        }
    }

    
    
    
}


