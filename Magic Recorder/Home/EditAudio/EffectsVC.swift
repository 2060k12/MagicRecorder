//
//  EffectsVC.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 11/8/2024.
//

import UIKit
import AudioKit
import AVFoundation


class EffectsVC: UIViewController, AVAudioPlayerDelegate {
   
        
    // all elemets of audio, for audio editing
    
    var engine = AudioEngine()
    var player = AudioPlayer()
    var delay : Delay!
    var reverb: Reverb!
    var buffer : AVAudioPCMBuffer!
    var timer : Timer?
    var maxTime : String!
    var recording: Recording!
    var currentPath : URL?
    var delegate : SendUrl?
    var finalURl : URL?
    
    // function which will show alert Message in the screen
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // slider which indicated current time
    @IBOutlet weak var currentAudioTimeSlider: UISlider!
    
    @IBOutlet weak var maxAudioTime: UILabel!
    @IBOutlet weak var currentAudioTime: UILabel!
    
    // sliders for delay effects
    @IBOutlet weak var feedback_delay: UISlider!
    
    @IBOutlet weak var timeDelay: UISlider!
    
    @IBOutlet weak var dryWetMixDelay: UISlider!
    
    
    
    // sliders for reverb effect
    
    @IBOutlet weak var dryWet_reverb: UISlider!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // file path in device
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsURL.appendingPathComponent(recording.name, conformingTo: .wav)
        
        // filepath if it's downloaded from online
        let onlineAudioFolderURL = documentsURL.appendingPathComponent("OnlineAudio", isDirectory: true)
        let fileURL = onlineAudioFolderURL.appendingPathComponent(recording.name).appendingPathExtension("wav")
        if FileManager.default.fileExists(atPath: fileURL.path) {
              // File exists locally, use this file URL
             currentPath = fileURL
        } else {
            
            currentPath = url
        }
        
                
        // Setup the audio session
          do {
              try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
              try AVAudioSession.sharedInstance().setActive(true)
          } catch {
              print("Failed to set up audio session: \(error.localizedDescription)")
          }
        
        
        // initialize delay effects sliders value
        feedback_delay.value = 0
        dryWetMixDelay.value = 0
        timeDelay.value = 0
        maxAudioTime.text = maxTime

        // initialize reverb value
        dryWet_reverb.value = 0
        
        delay = Delay(player)
        reverb = Reverb(delay)
        currentAudioTimeSlider.value = 0.0
       

    }
    
    
    
    // Finction to update slider when an audio is played
    func startTimer() {
        // Ensure the timer runs on the main thread for UI updates
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                // Ensure the player is playing and currentTime is valid
                guard self.player.isPlaying else {
                    timer.invalidate()
                    return
                }
                
                // Update the slider position
                self.currentAudioTimeSlider.value = Float(self.player.currentTime)
                
                // Format the current time and update the label
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .positional
                formatter.zeroFormattingBehavior = .pad
                
                if let formattedDuration = formatter.string(from: self.player.currentTime) {
                    self.currentAudioTime.text = formattedDuration
                }
            }
        }
    }

    
    @IBAction func currentAudioTImeSlider_OnChanged(_ sender: Any) {
        
      
    }
    
    
    // Below are functions which will handel effects of delay effect
    // controls feedback of delay
    @IBAction func feedBackSliders_Delay(_ sender: Any) {
        if let slider = sender as? UISlider {
            delay.feedback = slider.value
        }
        
    }
    
    // controls dry wet mix for delay
    @IBAction func dryWetMixSlider_Delay(_ sender: Any) {
        if let slider = sender as? UISlider {
            delay.dryWetMix = (slider.value * 100)
        }
        
    }
    
    // controls delay timer
    @IBAction func timeSlider_Delay(_ sender: Any) {
        if let slider = sender as? UISlider {
            delay.time = slider.value
        }
    }
    
    // functions for reverb effect
    
    @IBAction func dryWetMixSlider_Reverb(_ sender: Any) {
        if let slider = sender as? UISlider{
            reverb.dryWetMix = slider.value
        }
    }

    
    @IBAction func saveButton_OnPressed(_ sender: Any) {
        guard player.isPlaying else {
            alert(title: "Error", message: "Audio is not playing. Start playback before saving.")
            return
        }
        
        // Check if `currentPath` is available
        guard let currentPath = currentPath else {
            alert(title: "Error", message: "No file to save. Please load a valid file.")
            return
        }
        
        // Use the same file URL for the processed audio
        let processedFileURL = currentPath
        
        do {
            // Create an AVAudioFile to write the processed audio
            let format = player.buffer?.format
            guard let format = format else {
                alert(title: "Error", message: "Unable to retrieve audio format.")
                return
            }
            
            let outputFile = try AVAudioFile(forWriting: processedFileURL, settings: format.settings)
            
            // Create a new audio engine to process and render the audio
            let renderEngine = AudioEngine()
            let playerNode = AudioPlayer()
            let delayNode = Delay(playerNode)
            let reverbNode = Reverb(delayNode)
            
            // Set processing parameters
            delayNode.feedback = feedback_delay.value
            delayNode.time = timeDelay.value
            delayNode.dryWetMix = dryWetMixDelay.value * 100
            reverbNode.dryWetMix = dryWet_reverb.value
            
            // Connect nodes
            renderEngine.output = reverbNode
            playerNode.buffer = player.buffer
            playerNode.isLooping = false
            
            // Start the render engine
            try renderEngine.start()
            
            // Render audio to the output file
            let buffer = player.buffer
            guard let buffer = buffer else {
                alert(title: "Error", message: "Unable to retrieve audio buffer.")
                return
            }
            
            let _ = AVAudioFrameCount(buffer.frameLength)
            try outputFile.write(from: buffer)
            
            // Stop the engine and cleanup
            renderEngine.stop()
            
            // Update the delegate with the new URL
            finalURl = processedFileURL
            delegate?.passUrlBack(url: finalURl!)
            
            // Dismiss the view controller
            self.dismiss(animated: true, completion: nil)
            
        } catch {
            // Handle errors
            alert(title: "Error", message: "Failed to save audio: \(error.localizedDescription)")
        }
    }


    
    
    // when the play button is pressed
    @IBAction func playButton_onPressed(_ sender: Any) {
        
        
        guard let _ = recording else {
            print("No recording found")
            return
        }

        do {
            
            guard let url = currentPath else{
                print("Invalid URl")
                return
            }
            
               let file = try AVAudioFile(forReading: url)
               buffer = try AVAudioPCMBuffer(file: file)
                guard let buffer = buffer else {
                            print("Buffer is nil")
                            return
                        }
                
            
                // add effects to the audio when playing
                player = AudioPlayer(buffer: buffer)!
                player.isLooping = true
               
                delay = Delay(player)
                delay.feedback = feedback_delay.value
                delay.time = timeDelay.value
                delay.dryWetMix = dryWetMixDelay.value * 100
                engine.output = delay
            
                reverb = Reverb(delay)
                reverb.dryWetMix = dryWet_reverb.value
                engine.output = reverb
                currentAudioTime.text = "0:00"
            
                currentAudioTimeSlider.maximumValue = Float(player.duration)
                startTimer()
                
            
                // Check if the engine is already running
                    if !engine.avEngine.isRunning {
                        try engine.start()
                        print("Engine started")
                    } else {
                        print("Engine was already running")
                    }
               
               player.play()
            
            print("Playback started") // Debug: Confirm playback start

           } catch {
               print("Error: \(error.localizedDescription)")
           }
    }
    
        // when audio is stopped
    @IBAction func pauseButton_onPress(_ sender: Any) {
        
        if(player.isPlaying) {
            player.stop() // This stops the playback
        }
    }
    
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier ==  Const.EditScreenVC {
               let editVC = segue.destination as! EditScreenVC
               editVC.currentPath = finalURl
              
               
           }
       }

}

protocol SendUrl {
    func passUrlBack(url: URL)
}
