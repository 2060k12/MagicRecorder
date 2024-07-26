//
//  StoreTableVC.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit

class StoreTableVC: UITableViewController {
    
    
    let repository = StoreRepository()
    var listOfThemes = [Themes]()

    
    @IBOutlet var storeTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repository.getAllThemes() {
            themes in
            self.listOfThemes = themes
            self.storeTableView.reloadData()
            
        }

        for theme in listOfThemes {
            print(theme.themeName)

        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfThemes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! StoreTableViewCell
        let item = listOfThemes[indexPath.row]
        cell.themeNameLabel.text = item.themeName
        
        if !item.imageUrl.isEmpty && UIImage(named: item.imageUrl) != nil {
            cell.themeImageView.image = UIImage(named: item.imageUrl)
            
        }
        else {
            cell.themeImageView.image = UIImage(systemName: "person.circle.fill")
        }
        return cell
    }
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
