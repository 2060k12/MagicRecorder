//
//  ProfileViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
 

    var listOfRecordings = [Recording()]
    var selectedIndexPath : IndexPath?


    // UI elements for Profile View Screen
    @IBOutlet weak var profileImage: UIImageView!  // holds the profile picture of the current user
    @IBOutlet weak var currentUserName: UILabel!   // Full name of current User
    @IBOutlet weak var profileTable: UITableView!   // Table which will store all edited videos
    
    
    // WHen the Screen loads this function will run
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        // initializing repoisitory
        
        let repository = ProfileRepository()
        
    
        // async requests
        Task {
            
            do{
                let recordings  = try await repository.getAllRecordings()
                DispatchQueue.main.async {
                                    self.listOfRecordings = recordings
                                    self.profileTable.reloadData()
                                }
            }catch {
                print("Failed to retrieve recordings: \(error.localizedDescription)")
            }
            
            if let profile = await repository.getCurrentUserProfileInfo() {
                self.currentUserName.text = profile.fullName
                let url = URL(string: profile.profileImage)
                profileImage.kf.setImage(with: url)
            } else {
                print("User Not Found")
            }
        }
        profileTable.register( UINib(nibName: Const.EachRecordingCell, bundle: nil) , forCellReuseIdentifier: Const.EachRecordingCellReuse)
        profileTable.dataSource = self
        profileTable.delegate = self
        profileTable.reloadData()

      

    }
    
//    //  Everything related to table view in profile screen is below this line
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileTable.dequeueReusableCell(withIdentifier: Const.EachRecordingCellReuse, for: indexPath) as! EachRecordingCell
        cell.recordingNameLabel.text = listOfRecordings[indexPath.row].name
        cell.currentRecording = listOfRecordings[indexPath.row]
        cell.currentScreen = Const.Profile
        cell.syncOnOff.isEnabled = false

        return cell
    }
    
    // changes the height of the selected row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath  {
            return 200 // Height when selected
        }
    
        return 50 // Initial height
        
    }
    
    
    // when any row is selected it updates "selectedIndexPath" variable
    // which then will be used to change the height of the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    

   

}
