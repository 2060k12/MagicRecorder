//
//  LoginRepository.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class LoginRepository{
    
    
    // initializing firestore database
    let db = Firestore.firestore()
    
    // function to register as a new user
    func registerUser(user: Profile, password : String, callBack : @escaping(Bool) -> Void){
        
                // user details which will bestored in a firestore database
                var userDetail : [String: Any ] = [
                    "fullName" :user.fullName,
                    "email": user.email!,
                    "phoneNumber" : user.phoneNumber,
                    "premiumMember" : user.premiumMember,
                    "profileImage" : user.profileImage,
                    "registeredAt" : user.registeredAt!
                ]
                Auth.auth().createUser(withEmail: user.email!, password: password){
                    authResult, error in
                    guard error == nil else {
                        print("Cannot Create the account")
                        callBack(false)
                        return
                    }
                    self.db.collection("Users")
                        .document(user.email!)
                        .setData(userDetail){
                            error in
                            if let error = error {
                            
                                callBack(false)
                            }
                        }
                    
                    callBack(true)
                }
               
    }
    
    // function to login
    func login(email : String, password: String, callBack :@escaping (Bool) -> Void){
            Auth.auth().signIn(withEmail: email, password: password) {
                authResult, error in
                guard error == nil else {
                    callBack(false)
                    return
                }
                callBack(true)
            }
    }
}
