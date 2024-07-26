//
//  LoginRepository.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import Foundation
import FirebaseAuth


class LoginRepository{
    
    // function to register as a new user
    func registerUser(email : String?, password : String?, callBack : @escaping(Bool) -> Void){
        if(!email.isNilOrWhiteSpace || !password.isNilOrWhiteSpace){
            Auth.auth().createUser(withEmail: email!, password: password!){
                authResult, error in
                guard error == nil else {
                    print("Cannot Create the account")
                    callBack(false)
                    return
                }
                callBack(true)
                
            }
        }
    }
    
    // function to login
    func login(email : String?, password: String?, callBack :@escaping (Bool) -> Void){
        if(!email.isNilOrWhiteSpace || !password.isNilOrWhiteSpace){
            Auth.auth().signIn(withEmail: email!, password: password!) {
                authResult, error in
                guard error == nil else {
                    callBack(false)
                    return
                }
                callBack(true)
            }
            
        }
        
    }
}
