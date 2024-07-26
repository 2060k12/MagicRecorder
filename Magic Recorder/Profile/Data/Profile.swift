//
//  Profile.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import Foundation
import FirebaseFirestore


class Profile{
    let fullName : String
    let profileImage : String
    let premiumMember : Bool
    let registeredAt : Timestamp?
    let email :String!
    let phoneNumber : String
    
    
    
    // default constructer for our class
    init(fullName: String, profileImage: String, premiumMember: Bool, registeredAt: Timestamp?, email: String, phoneNumber : String) {
        self.fullName = fullName
        self.profileImage = profileImage
        self.premiumMember = premiumMember
        self.registeredAt = registeredAt
        self.email = email
        self.phoneNumber = phoneNumber
    }
    
    
    // constructer used to regester a new user
    convenience init(fullName: String, email: String, phoneNumber: String){
        self.init(fullName: fullName,
                  profileImage: "",
                  premiumMember: false,
                  registeredAt: Timestamp.init(),
                  email: email,
                  phoneNumber: phoneNumber)
    }
    
    
    // constructer which will be used when getting data from database
    convenience init(dictionary:[String : Any]){
        
        self.init(fullName: dictionary["firstName"] as! String,
                  profileImage: dictionary["profileImage"] as! String,
                  premiumMember: dictionary["profileImage"] as! Bool,
                  registeredAt: dictionary["registeredAt"] as? Timestamp ,
                  email: dictionary["profileImage"] as! String,
                  phoneNumber: dictionary["phoneNumber"] as! String)
        
    }
    
}
