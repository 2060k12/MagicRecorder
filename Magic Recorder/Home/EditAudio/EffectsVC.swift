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

    var engine = AudioEngine()
    var player = AudioPlayer()
    var delay : Delay!
    var reverb: Reverb!
    var buffer : AVAudioPCMBuffer!
    var timer : Timer?
    var maxTime : String!
    var recording: Recording!

    
    
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

    
    
    
    
    @IBAction func playButton_onPressed(_ sender: Any) {
        
        
        guard let recording = recording else {
            print("No recording found")
            return
        }
        
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsURL.appendingPathComponent(recording.name, conformingTo: .wav)
        print("Playing file at URL: \(url)") // Debug: Check the file path

        do {
               let file = try AVAudioFile(forReading: url)
               buffer = try AVAudioPCMBuffer(file: file)
            guard let buffer = buffer else {
                        print("Buffer is nil")
                        return
                    }
                
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
    
    @IBAction func pauseButton_onPress(_ sender: Any) {
        player.stop() // This stops the playback

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
