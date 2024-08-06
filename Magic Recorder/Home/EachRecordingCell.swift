//
//  EachRecordingCell.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 5/8/2024.
//

import UIKit
import AVFoundation

class EachRecordingCell: UITableViewCell, AVAudioPlayerDelegate {
    

    

    
    var audioPlayer: AVAudioPlayer!
    var currentRecording : URL!
    
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
    
    @IBAction func playButton_onClick(_ sender: Any) {
        
        playRecording()
    }
    
    
    func playRecording() {
            // Convert NSURL to URL if needed
            guard let url = currentRecording else {
                print("No recording URL set")
                return
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch let error as NSError {
                print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
            }
        }
        
            
        }
    
    
    
    

