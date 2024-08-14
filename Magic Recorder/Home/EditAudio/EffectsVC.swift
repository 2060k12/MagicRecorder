//
//  EffectsVC.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 11/8/2024.
//

import UIKit
import AudioKit
import AVFoundation


class EffectsVC: UIViewController {

    var engine = AudioEngine()
    var player = AudioPlayer()
    var delay : Delay!
    var reverb: Reverb!
    var buffer : AVAudioPCMBuffer!
    
    
    
    // sliders for delay effects
    @IBOutlet weak var feedback_delay: UISlider!
    
    @IBOutlet weak var timeDelay: UISlider!
    
    @IBOutlet weak var dryWetMixDelay: UISlider!
    
    
    
    // sliders for reverb effect
    
    @IBOutlet weak var dryWet_reverb: UISlider!
    
    @IBOutlet weak var chooseRoomSize_Reverb: UIButton!
    
    
    var recording: Recording!
    
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
        
        // initialize reverb value
        dryWet_reverb.value = 0
        
       

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
            delay.dryWetMix = slider.value
        }
    }
    
    // functions for reverb effect
    
    @IBAction func dryWetMixSlider_Reverb(_ sender: Any) {
        if let slider = sender as? UISlider{
            reverb.dryWetMix = slider.value
        }
    }
    
    @IBAction func reverb_room_Select(_ sender: Any) {
        
        guard let button = sender as? UIButton else {
                   print("Sender is not a UIButton")
                   return
               }
        
        
        let select = UIAlertController(title: "Select Room Size", message: nil, preferredStyle: .actionSheet)
            switch select.title {
            case "Select Reverb Room Size" :
                
                return
            case "Small Room" :
                reverb.loadFactoryPreset(.smallRoom)
                return
            case "Medium Room" :
                reverb.loadFactoryPreset(.mediumRoom)
                return
            case "Large Room" :
                reverb.loadFactoryPreset(.largeRoom)
                return
            case "Hall" :
                reverb.loadFactoryPreset(.largeHall)
                return
            default:
                print("Unknown reverb preset selected")
            }
        
        
            select.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(select, animated: true, completion: nil)

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
            reverb.loadFactoryPreset(.largeRoom2)
            
            
            engine.output = reverb
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
