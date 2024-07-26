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
    var userDetails: Profile?
    
     func getCurrentUserProfileInfo(){
         let dbRef = db.collection("Users")
             .document("iampranish@Outlook.com")
             
         
     }
    
    
    
    
}
