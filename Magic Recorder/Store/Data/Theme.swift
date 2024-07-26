//
//  Theme.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import Foundation

class Themes{
    let themeName : String
    let price: Double
    let imageUrl: String
    
    // default constructer
    init(themeName: String, price: Double, imageUrl: String) {
        self.themeName = themeName
        self.price = price
        self.imageUrl = imageUrl
    }
    
    // constructer which takes dictionary in
    convenience init(dictionary : [String : Any]){
        self.init(themeName: dictionary["themeName"] as! String,
                  price: dictionary["price"] as! Double,
                  imageUrl: dictionary["imageUrl"] as! String
        )
    }
    
    
}
