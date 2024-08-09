//
//  ProfileViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
 

    var listOfVideos: [URL]?
    
    let db = OfflineRepository() // Initializing realmDB
    
    
    // UI elements for Profile View Screen
    @IBOutlet weak var profileImage: UIImageView!  // holds the profile picture of the current user
    @IBOutlet weak var currentUserName: UILabel!   // Full name of current User
    @IBOutlet weak var profileTable: UITableView!   // Table which will store all edited videos
    
    
    // WHen the Screen loads this function will run
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        db.getAllRecordings().forEach { video in
            let url = documentsURL.appendingPathComponent(video.name, conformingTo: .movie)
            listOfVideos?.append(url)
            
        }
        
        
        // initializing repoisitory
        let repository = ProfileRepository()

        // async requests
        Task {
            if let profile = await repository.getCurrentUserProfileInfo() {
                self.currentUserName.text = profile.fullName
                let url = URL(string: profile.profileImage)
                profileImage.kf.setImage(with: url)
            } else {
                print("User Not Found")
            }
        }

    }
    
//    //  Everything related to table view in profile screen is below this line
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileTable.dequeueReusableCell(withIdentifier: Const.ProfileCell, for: indexPath) as! ProfileCellVC
//        cell.nameLabel =

        return cell
    }
    
    

   

}
