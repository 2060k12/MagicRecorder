//
//  EachRecordingCell.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 5/8/2024.
//

import UIKit

class EachRecordingCell: UITableViewCell {
    
    
    @IBOutlet weak var recordingUiView: UIView!
    
    @IBOutlet weak var recordingNameLabel: UILabel!
    @IBOutlet weak var recordingLengthLabel: UILabel!
    
    @IBOutlet weak var goBackwardButton: UIButton!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var goForwardButton: UIButton!
    
    @IBOutlet weak var recordingSlider: UISlider!
    
    @IBOutlet weak var editRecordingButton: UIButton!
    
    @IBOutlet weak var moreMenuButton: UIButton!
    
    @IBOutlet weak var sliderMaxLengthLabel: UILabel!
    
    

     override func awakeFromNib() {
         super.awakeFromNib()
      
     }

     override func setSelected(_ selected: Bool, animated: Bool) {
        
     }
    
}
