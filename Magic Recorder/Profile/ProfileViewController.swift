//
//  ProfileViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit

class ProfileViewController: UIViewController {

    // initializing Profile repository
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var currentUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let repository = ProfileRepository()
        repository.getCurrentUserProfileInfo()
        let currentUserDetails = repository.userDetails
        
        currentUserName.text = currentUserDetails?.fullName
        
        
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
