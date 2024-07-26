//
//  StoreRepository.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
class StoreRepository{
    
    
    // initializing firestore database
    let db = Firestore.firestore()
  
    
    
    func getAllThemes( callback : @escaping ([Themes]) -> Void ){
        
        var tempList = [Themes]()
  
            db.collection("Store")
            .addSnapshotListener{querySnapshot, error in
               
                if let document = querySnapshot?.documents {
                    tempList = document.compactMap({
                        querySnapshot -> Themes? in
                        let data = querySnapshot.data()
                        return Themes(dictionary: data)
                    })

                }
            
                callback(tempList)

            }
        
        
    }
    
    
}
