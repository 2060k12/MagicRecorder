//
//  EachRecordingCell.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 5/8/2024.
//

import UIKit

class EachRecordingCell: UITableViewCell {
    
    
    
    @IBOutlet weak var recordingNameLabel: UILabel!
    @IBOutlet weak var recordingLengthLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
