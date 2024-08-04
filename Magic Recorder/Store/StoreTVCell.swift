//
//  StoreTVCell.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 3/8/2024.
//

import UIKit

class StoreTVCell: UITableViewCell {

    
    @IBOutlet weak var themeNameLabel: UILabel!
    @IBOutlet weak var themeImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        themeImageView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
