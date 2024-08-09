//
//  UnsplashImagePicker.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 9/8/2024.
//

import Foundation
import UnsplashPhotoPicker
import UIKit

extension EditScreenVC : UnsplashPhotoPickerDelegate {
    
    
    func convertUnsplashImgToImage(photo :UnsplashPhoto, success: @escaping (UIImage?)-> Void ) {
        guard let imageUrlSting = photo.urls.first, let  imageUrl = URL(string: imageUrlSting.value.absoluteString) else {
            success(nil)
            return
            
        }
        // Create a URLSession data task to fetch the image data
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            // Check for errors and ensure data is not nil
            guard let data = data, error == nil else {
                print("Error downloading image: \(String(describing: error))")
                success(nil)
                return
            }
            
            // Create a UIImage from the downloaded data
            let image = UIImage(data: data)
            success(image)
        }
        
        // Start the download task
        task.resume()
        
    }
    
    
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        if let selectedImage = photos.first {
            convertUnsplashImgToImage(photo: selectedImage) { img in
                
                DispatchQueue.main.async {
                    self.editImageView.image = img
                    self.image = img
                }
                
            }
            
            
        }
        noImageLabel.isHidden = true
        addImageButton.isHidden = true
        addUnsplashImageButton.isHidden = true
    
        
    }
    
    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        
    }
    
}
