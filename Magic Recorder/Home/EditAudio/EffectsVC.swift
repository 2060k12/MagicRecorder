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
    var buffer : AVAudioPCMBuffer!
    
    
    
    var recording: Recording!
    
    @IBOutlet weak var delaySlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addDelayButton_onPressed(_ sender: Any) {
        
        
    }
    
    
    
    @IBAction func playButton_onPressed(_ sender: Any) {
        guard let recording = recording else {
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsURL.appendingPathComponent(recording.name, conformingTo: .wav)
        
        do {
               let file = try AVAudioFile(forReading: url)
               buffer = try AVAudioPCMBuffer(file: file)
                player = AudioPlayer(buffer: buffer)!
               player.isLooping = true
               
               delay = Delay(player)
               delay.feedback = 0.9
               delay.time = 0.01
               delay.dryWetMix = 100
               
               engine.output = delay
               try engine.start()
               
               player.play()
           } catch {
               print("Error: \(error.localizedDescription)")
           }
    }
    
    @IBAction func pauseButton_onPress(_ sender: Any) {
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
