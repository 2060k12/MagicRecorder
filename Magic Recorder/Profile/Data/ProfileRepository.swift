//
//  ProfileRepository.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ProfileRepository {
    let db = Firestore.firestore()
    
    
    // get currentUser
    var currentUSer = Auth.auth().currentUser?.email
    
    
    func getCurrentUserProfileInfo() async -> Profile? {
        do {
            let snapshot = try await db.collection("Users")
                .document("iampranish@Outlookk.com")
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

    
    
    
}
