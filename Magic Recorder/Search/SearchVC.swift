//
//  SearchVC.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 11/8/2024.
//

import UIKit
import Kingfisher

class SearchVC: UIViewController, UISearchBarDelegate {
    // UI elements
    @IBOutlet weak var searchedUserTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchedProfile : Profile?
    let repository = SearchRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Search users"
        searchBar.delegate = self
        
        searchedUserTableView.delegate = self
        searchedUserTableView.dataSource = self
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text ?? "None")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            
            repository.searchUser(searchedText: searchText.lowercased()) { profile in
                self.searchedProfile = profile
                self.searchedUserTableView.reloadData()
                
            }
        }
    }
}

/// For table stuffs

extension SearchVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  searchedProfile != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchedUserTableView.dequeueReusableCell(withIdentifier: Const.searchedTableCell) as! searchedUserCell
        cell.userNameLabel.text = searchedProfile?.fullName
        
        
        
        //        if let imageUrlString = self.searchedProfile?.profileImage, let imageUrl = URL(string: imageUrlString) {
        //                   cell.userImageView.kf.setImage(
        //                       with: imageUrl,
        //                       placeholder: UIImage(named: "placeholder"), // Optional placeholder image
        //                       options: [
        //                           .transition(.fade(0.2)), // Optional transition effect
        //                           .cacheOriginalImage // Cache the original image
        //                       ]
        //                   )
        //               } else {
        //                   // Handle the case where URL is invalid or nil
        //                   cell.userImageView.image = UIImage(named: "placeholder") // Use placeholder or default image
        //                   print("Image URL is invalid")
        //               }
                return cell
            }
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let profile = searchedProfile else {
                print("No Profile Selected")
                return
            }
            
            // navigates to the profile destination
            
            // Instantiate ProfileViewController from the storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let destinationVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
                print("Failed to instantiate ProfileViewController from storyboard")
                return
            }
            
            destinationVC.currentProfile = searchedProfile
            navigationController?.pushViewController(destinationVC, animated: true)
            
            //  deselect the current cell
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
