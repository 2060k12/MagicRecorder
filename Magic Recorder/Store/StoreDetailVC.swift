//
//  StoreVC.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 2/8/2024.
//

import UIKit

class StoreDetailVC: UIViewController {

    var theme : Themes?
    
    @IBOutlet weak var productDetailTextView: UITextView!
    @IBOutlet weak var productImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productDetailTextView.text = theme?.themeName
       
        // productImageView
        if let imageUrlString = theme?.imageUrl, let url = URL(string: imageUrlString) {
                 productImageView.kf.setImage(with: url)
             } else {
                 productImageView.image = UIImage(systemName: "photo") // Fallback image
             }


        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addProductButton_onClick(_ sender: Any) {
    }
    @IBAction func cancelButton_onClick(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
