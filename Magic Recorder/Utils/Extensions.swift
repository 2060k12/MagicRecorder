//
//  Extensions.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 25/7/2024.
//

import Foundation


extension Optional where Wrapped == String {
    
    var isNilOrWhiteSpace : Bool {
        guard let notNilBool = self else {
            return true
        }
        
        return notNilBool.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
}



extension String{
    var isWhiteSpace : Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}


