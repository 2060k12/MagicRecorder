//
//  Extensions.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 25/7/2024.
//

import Foundation



// extension function for optionals which have string inside
extension Optional where Wrapped == String {
    
    // this function checks if an optional value's string is null has space or not
    
    var isNilOrWhiteSpace : Bool {
        guard let notNilBool = self else {
            return true
        }
        
        return notNilBool.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
}

// extension for datatype String
extension String{
    
    // removed the whitespace fromt he string
    var isWhiteSpace : Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}


