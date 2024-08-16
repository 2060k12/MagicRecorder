//
//  EachRecordingCell.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 5/8/2024.
//

import UIKit
import AVFoundation
import AudioStreaming

class EachRecordingCell: UITableViewCell, AVAudioPlayerDelegate {
    
    let db = OfflineRepository()
    let profileRepo = ProfileRepository()
    
    var timer: Timer?

    
    // indicates which screen the user view this cell from
    var currentScreen : String!
    
    var audioPlayer: AVAudioPlayer!
    var currentRecording : Recording!
    
    @IBOutlet weak var syncOnOff: UISwitch!
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
    
    
    
    
    @IBAction func goBackward_OnPressed(_ sender: Any) {
        guard let player = audioPlayer else {
               print("Audio player not initialized")
               return
           }
           
           // Go backward by 5 seconds
           let newTime = player.currentTime - 5
           player.currentTime = max(newTime, 0) // Ensure the time doesn't go below 0
           recordingSlider.value = Float(player.currentTime)
        
    }
    
    @IBAction func goForward_OnPressed(_ sender: Any) {
        guard let player = audioPlayer else {
               print("Audio player not initialized")
               return
           }
           
           // Go forward by 5 seconds
           let newTime = player.currentTime + 5
           player.currentTime = min(newTime, player.duration) // Ensure the time doesn't exceed the duration
           recordingSlider.value = Float(player.currentTime)
        
    }
    
        
    @IBAction func playButton_onClick(_ sender: Any) {
        if audioPlayer?.isPlaying == true {
               stopRecording()
           } else {
               playRecording()
           }
    }
    
    
    // function to stop the current recording if audio is being played
    func stopRecording() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            timer?.invalidate()
            
            // Reset the player to the beginning
            audioPlayer.currentTime = 0
            recordingSlider.value = 0
            
         
            // Change button icon back to "Play"
            let playIcon = UIImage(systemName: "play.fill") // System icon for play
            playPauseButton.setImage(playIcon, for: .normal)
        }
    }

    // when the audio is finished playing, this function will change the icon
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Reset the play button icon to "Play"
        let playIcon = UIImage(systemName: "play.fill")
        playPauseButton.setImage(playIcon, for: .normal)
        
        // Stop the timer
        timer?.invalidate()
        recordingSlider.value = 0
    }

    
    
    @IBAction func deleteRecording_onClick(_ sender: Any) {
        
        switch currentScreen {
            
        case Const.HomeScreen:
            db.removeRecording(recording: currentRecording)
            break
            
        case Const.Profile:
            profileRepo.removeFromTheCloud(recording: currentRecording) { result  in
                switch result {
                case .success():
                    print("Successfully Deleted")
                case .failure(_):
                    print("Something went wrong")
                }
                
            }
            break
            
        case .none:
            print("Can't delete rn")
            break
            
        case .some(_):
            print("SOmethig is not right")
            break
        }
        
        
    }
  
    
    func startTimer(){
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { Timer in
            if let player = self.audioPlayer {
                self.recordingSlider.value = Float(player.currentTime)
            }
        })
    }
    
    func playRecording() {
        
        
        switch currentScreen {
            
            // when the user is in home screen
        case Const.HomeScreen :
            
            guard let record = currentRecording else {
              
                print("No recording URL set")
                return
            }
            
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsURL.appendingPathComponent(record.name, conformingTo: .wav)
            
            do{
                
                if audioPlayer == nil {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.delegate = self
                    audioPlayer?.prepareToPlay()
                    recordingSlider.maximumValue = Float(audioPlayer.duration)
                    
                }
                // Set the player to the slider's current position or to the beginning
                audioPlayer.currentTime = Double(recordingSlider.value)
                audioPlayer?.play()
                startTimer()
                
                // Change button to "Stop"
                 let stopIcon = UIImage(systemName: "stop.fill") // System icon for stop
            playPauseButton.setImage(stopIcon, for: .normal)
            } catch let error as NSError {
                print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
                
            }
            break
            
            
        case Const.Profile :
            guard let record = currentRecording else {
                print("No recording URL set")
                return
            }
            
            guard let url = URL(string: record.savedPath) else {
                   print("URL is null or invalid")
                   return
               }
            
            do{
                if audioPlayer == nil {
                    URLSession.shared
                        .dataTask(with: url) { [self]  data , response, error in
                            
                            if let error = error {
                                print("Download error: \(error)")
                                return
                            }
                            
                            guard let data = data else {
                                print("No data found")
                                return
                            }
                            
                            do {
                                let player = try AVAudioPlayer(data: data)
                                player.delegate = self
                                player.prepareToPlay()
                                
                                DispatchQueue.main.async {
                                    self.recordingSlider.maximumValue = Float(player.duration)
                                }
                                
                                player.play()
                            } catch {
                                print("Error initializing AVAudioPlayer: \(error)")
                            }
                            
                            // Set the player to the slider's current position or to the beginning
                            DispatchQueue.main.async {
                                self.audioPlayer.currentTime = Double(self.recordingSlider.value)
                                self.audioPlayer.play()
                                self.startTimer()
                                // Change button to "Stop"
                                let stopIcon = UIImage(systemName: "stop.fill") // System icon for stop
                                self.playPauseButton.setImage(stopIcon, for: .normal)
                            }
                            
                        }
                    
          
                    .resume()
            } else {
                // If the player already exists, just resume playback
                audioPlayer.currentTime = Double(recordingSlider.value)
                audioPlayer.play()
                startTimer()
                
                // Change button to "Stop"
                 let stopIcon = UIImage(systemName: "stop.fill") // System icon for stop
            playPauseButton.setImage(stopIcon, for: .normal)
            }
                
                
            } catch let error as NSError {
                print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
                
            }
            
            break
            
        case .none:
            print("Cant play rn")
            
        case .some(_):
            print("Something is not right")
        }
    }
    
    
    
    @IBAction func synchStatusChange(_ sender: Any) {
        if syncOnOff.isOn {
            profileRepo.addRecordingToCloud(recording: currentRecording) { result in
                switch result {
                case .success(()):
                    print("Done")
                    self.syncOnOff.isOn = true
                    break
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.syncOnOff.isOn = false

                }
            }
        }
        
        
        if !syncOnOff.isOn {
            profileRepo.removeFromTheCloud(recording: currentRecording) { result in
                switch result {
                case .success(()):
                    print("removed")
                    break
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.syncOnOff.isOn = true
                }
            }
        }
        
    }
}
    

