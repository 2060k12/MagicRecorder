//
//  EditScreenVC.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 30/7/2024.
//

import UIKit
import AVFoundation
import SwiftVideoGenerator
import Photos
import UnsplashPhotoPicker


class EditScreenVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioPlayerDelegate{
   

    
    // getting recording while navigating
    var recording : Recording!
    var image :UIImage?
    var imagePicker = UIImagePickerController()
    var timer : Timer?
    var startTime = 0.0
    var audioUrl : URL?
    
    
    // ui elements
    
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var audioMaxLengthLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! // reference to play and pause button
    @IBOutlet weak var audioSlider: UISlider! // reference to audio slider (changes according to duration)
    @IBOutlet weak var audioCurrentTimeLabel: UILabel! // current time label of audio
    
    @IBOutlet weak var addUnsplashImageButton: UIButton!
    
    
    func startTimer(){
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { Timer in
            if let player = self.audioPlayer {
                self.audioSlider.value = Float(player.currentTime)
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .positional
                formatter.zeroFormattingBehavior = .pad
                
                if let formattedDuration = formatter.string(from: player.currentTime) {
                    self.audioCurrentTimeLabel.text = formattedDuration
                }
            }
        })
    }
    
    @IBAction func sliderPosition_onChanged(_ sender: Any) {
        startTime = Double(audioSlider.value)
        
    }
    
    
    
    
    // audio player
    var audioPlayer : AVAudioPlayer?

    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        progressBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsURL.appendingPathComponent(recording.name, conformingTo: .mpeg4Audio)
        audioUrl = url
        audioSlider.value = Float(startTime)
        
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            if let audioPlayer = audioPlayer{
                audioSlider.maximumValue = Float(audioPlayer.duration)
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .positional
                formatter.zeroFormattingBehavior = .pad
                
                if let formattedDuration = formatter.string(from: audioPlayer.duration) {
                audioMaxLengthLabel.text = formattedDuration
            }
                
            }
        }catch {
            print("Error Playing Audio in edit Screen: \(error.localizedDescription)")
        }
        
    }
    
    
    @IBAction func playButton_onClicked(_ sender: Any) {
        audioPlayer?.play()
        startTimer()
        
    }
    
    // Pick image and crop from the gallary
    @IBAction func addImageButton_onPressed(_ sender: Any) {

        imagePicker.delegate = self
                 imagePicker.sourceType = .savedPhotosAlbum
                 imagePicker.allowsEditing = true

                 present(imagePicker, animated: true, completion: nil)
        
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            editImageView.image = editedImage
            image = editedImage
            
        }else if let originalImage = info[.originalImage] as? UIImage {
            editImageView.image = originalImage
        }
        picker.dismiss(animated: true)
        addImageButton.isHidden = true
        noImageLabel.isHidden = true
        addUnsplashImageButton.isHidden = true
    }
    
    

    // Todo:: ALert User
    @IBAction func saveEditedVideo_onClick(_ sender: Any) {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                if let image = self.image, let audioUrl = self.audioUrl {
                    let images = [image]
                    let audioUrls = [audioUrl]
                    
                    // Show the progress bar before starting the generation
                               DispatchQueue.main.async {
                                   self.progressBar.isHidden = false
                                   self.progressBar.setProgress(0.0, animated: true)
                               }
                    
                    VideoGenerator.current.generate(withImages: images, andAudios: audioUrls, andType: .single) { progeress in
                        print("Working")

                        DispatchQueue.main.async {
                            self.progressBar.setProgress(Float(progeress.fractionCompleted), animated: true)
                            print(progeress.fractionCompleted)
                        }

                        
                    } outcome: { (result) in
                        
                        switch result {
                        case .success(let videoUrl):
                            PHPhotoLibrary.shared().performChanges {
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
                                DispatchQueue.main.async {
                                    self.progressBar.isHidden = true
                                }
                                
                            }
                            break
                            
                        case .failure(let err):
                            print("Unable to export Video \(err.localizedDescription)")
                            
                            
                        }
                        print(result)
                        
                                             }
                    
                    }
                
        
            case .denied, .restricted, .notDetermined:
                print("Permission access was denied")
               
            @unknown default:
                break
            }
           
        }
        
    }
    

    
    @IBAction func unsplashPhotoPickerButton_onClick(_ sender: Any) {
        
        
        let config = Config()
        let picker = UnsplashPhotoPicker(configuration: config.unsplashConfig)
        picker.photoPickerDelegate = self
        present(picker, animated: true)
        
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




