//
//  StoreTableVC.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit
import Kingfisher
class StoreTableVC: UITableViewController {
    
    // initializing Store repsitory
    let repository = StoreRepository()
    var listOfThemes = [Themes]()
    var pressedItem : Themes?
    
    @IBOutlet var storeTableView: UITableView!
    
    // when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: const.StoreCell, bundle: nil), forCellReuseIdentifier: const.StoreCellReuse)

        
        
        // get all themes from the database
        repository.getAllThemes() {
            themes in
            self.listOfThemes = themes
            self.storeTableView.reloadData()
        }

        for theme in listOfThemes {
            print(theme.themeName)

        }

    
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfThemes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: const.StoreCellReuse, for: indexPath) as! StoreTVCell
        let item = listOfThemes[indexPath.row]
        cell.themeNameLabel.text = item.themeName
        
        
        // Mark : Todo Fix
        if !item.imageUrl.isEmpty, let url = URL(string: item.imageUrl) {
            cell.themeImageView.kf.indicatorType = .activity
            cell.themeImageView.kf.setImage(with: url)
            cell.themeImageView.image = UIImage(systemName: "person.circle.fill")

        } else {
            cell.themeImageView.image = UIImage(systemName: "person.circle.fill")
        }
        return cell
       
    }
    
 
    
    // when an item is pressed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pressedItem = listOfThemes[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        if let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "StoreDetailVC") as? StoreDetailVC{
            destinationVC.theme = pressedItem

            self.navigationController?.pushViewController(destinationVC, animated: true)
            
        }
        
        
    }
   
}
