//
//  EachRecordingCell.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 5/8/2024.
//

import UIKit
import AVFoundation

class EachRecordingCell: UITableViewCell, AVAudioPlayerDelegate {
    
    let db = OfflineRepository()
    
    var timer: Timer?

    
    var audioPlayer: AVAudioPlayer!
    var currentRecording : Recording!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var recordingUiView: UIView!
    
    @IBOutlet weak var recordingNameLabel: UILabel!
    @IBOutlet weak var recordingLengthLabel: UILabel!
    
    @IBOutlet weak var goBackwardButton: UIButton!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var goForwardButton: UIButton!
    
    @IBOutlet weak var recordingSlider: UISlider!
    
    @IBOutlet weak var editRecordingButton: UIButton!
    
    @IBOutlet weak var sliderMaxLengthLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        

        }
        
    @IBAction func playButton_onClick(_ sender: Any) {
        
        playRecording()
    }
    
    
    @IBAction func deleteRecording_onClick(_ sender: Any) {
        
        db.removeRecording(recording: currentRecording)
        
    }
  
    
    func startTimer(){
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { Timer in
            if let player = self.audioPlayer {
                self.recordingSlider.value = Float(player.currentTime)
            }
        })
    }
    
    func playRecording() {
       
        guard let record = currentRecording else {
            print("No recording URL set")
            return
        }
       
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsURL.appendingPathComponent(record.name, conformingTo: .mpeg4Audio)
            
        do{
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                recordingSlider.maximumValue = Float(audioPlayer.duration)
                audioPlayer?.play()
                startTimer()
                
            } catch let error as NSError {
                print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
            
        }
    }
}
    

