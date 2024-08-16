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




class EditScreenVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioPlayerDelegate, SendUrl{
    
    
    func passUrlBack(url: URL) {
        currentPath = url
    }
    
   

    var recording : Recording!     // getting recording while navigating
    let db = OfflineRepository()    // initializing realmDB

    

    var image :UIImage?
    var imagePicker = UIImagePickerController()
    var timer : Timer?
    var startTime = 0.0
    var audioUrl : URL?
    var maxLength : String?
    var currentPath : URL?
    
    
    // ui elements
    
    @IBOutlet weak var effectsButton: UIButton!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var audioMaxLengthLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! // reference to play and pause button
    @IBOutlet weak var audioSlider: UISlider! // reference to audio slider (changes according to duration)
    @IBOutlet weak var audioCurrentTimeLabel: UILabel! // current time label of audio
    @IBOutlet weak var addUnsplashImageButton: UIButton!    // Add images from unsplash.com
    
    
    // function which will show alert Message in the screen
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
                        self.present(alert, animated: true, completion: nil)}
    
    
    // Finction to update slider when an audio is played
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
        let url = documentsURL.appendingPathComponent(recording.name, conformingTo: .wav)
        
        let onlineAudioFolderURL = documentsURL.appendingPathComponent("OnlineAudio", isDirectory: true)
        let fileURL = onlineAudioFolderURL.appendingPathComponent(recording.name).appendingPathExtension("wav")
        if FileManager.default.fileExists(atPath: fileURL.path) {
              // File exists locally, use this file URL
             currentPath = fileURL
        } else {
            
            currentPath = url
        }
        
        audioUrl = url
        audioSlider.value = Float(startTime)
        
        
        do{
            guard let currentPath = currentPath else{
                print("Path is Nil")
                return
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: currentPath)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
                  if let audioPlayer = audioPlayer{
                      audioSlider.maximumValue = Float(audioPlayer.duration)
                      
                      let formatter = DateComponentsFormatter()
                      formatter.allowedUnits = [.minute, .second]
                      formatter.unitsStyle = .positional
                      formatter.zeroFormattingBehavior = .pad
                      
                      if let formattedDuration = formatter.string(from: audioPlayer.duration) {
                          maxLength = formattedDuration
                          audioMaxLengthLabel.text = maxLength
                      }
                  
                
            }
        }catch {
            print("Error Playing Audio in edit Screen: \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func effectsButton_onClick(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Ensure "Main" is your storyboard name
           let destinationVC = storyboard.instantiateViewController(withIdentifier: "EffectsVC") as! EffectsVC
           destinationVC.recording = recording
        guard let time = maxLength else {
            print("Audio is empty")
            return
        }
            destinationVC.maxTime = time
           self.present(destinationVC, animated: true)
        
        
    }
    
    // whne the play button is played
    @IBAction func playButton_onClicked(_ sender: Any) {
        if let player = audioPlayer {
              if player.isPlaying {
                  player.pause()
                  updatePlayPauseButton()
              } else {
                  player.play()
                  startTimer()
                  updatePlayPauseButton()
              }
          }
        
    }
    
    // after the current recoring is completed
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.updatePlayPauseButton()
        }
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
    
    
    
    private func updatePlayPauseButton() {
        let playIcon = UIImage(systemName: "play.fill")  // System icon for play
        let stopIcon = UIImage(systemName: "stop.fill")  // System icon for stop
        
        if let player = audioPlayer, player.isPlaying {
            playPauseButton.setImage(stopIcon, for: .normal)
        } else {
            playPauseButton.setImage(playIcon, for: .normal)
        }
    }
    

    // Todo:: ALert User
    @IBAction func saveEditedVideo_onClick(_ sender: Any) {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                if let image = self.image, let audioUrl = self.currentPath {
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
//                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
                                self.saveVideoToCustomAlbum(videoUrl: videoUrl)

                                DispatchQueue.main.async {
                                    self.progressBar.isHidden = true
                                    let video = EditedVideos(videoName: self.recording.name, videosPath: videoUrl.absoluteString, date: Date())
                                    self.db.insertVideo(video: video)
                                    self.alert(title: "Success", message: "Video Exported Successfully")
                                    
                                }
                               
                                
                            }
                            break
                            
                        case .failure(let err):
                            self.alert(title: "Error", message: err.localizedDescription)
                            
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
    
    
    
    // Save video to a custom album
    private func saveVideoToCustomAlbum(videoUrl: URL) {
        let albumName = "MagicRecorder"
        
        // Find or create the album
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let albumChangeRequest: PHAssetCollectionChangeRequest
            if let album = self.fetchAssetCollectionForAlbum(albumName: albumName) {
                albumChangeRequest = PHAssetCollectionChangeRequest(for: album)!
            } else {
                albumChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
            let assetPlaceholder = assetChangeRequest?.placeholderForCreatedAsset
            let fastEnumeration = NSArray(array: [assetPlaceholder!] as [Any])
            albumChangeRequest.addAssets(fastEnumeration)
            albumPlaceholder = assetPlaceholder
        }) { success, error in
            DispatchQueue.main.async {
                self.progressBar.isHidden = true
                if success {
                    if albumPlaceholder != nil {
                        let video = EditedVideos(videoName: self.recording.name, videosPath: videoUrl.absoluteString, date: Date())
                        self.db.insertVideo(video: video)
                        // Remove the video file from the file manager
                                          do {
                                              try FileManager.default.removeItem(at: videoUrl)
                                              print("Original video file removed from file manager.")
                                          } catch {
                                              print("Error deleting original video file: \(error.localizedDescription)")
                                          }
                    }
                } else if let error = error {
                    print("Error saving video to custom album: \(error.localizedDescription)")
                }
            }
        }
    }

    // Helper function to fetch asset collection
    private func fetchAssetCollectionForAlbum(albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collection.firstObject
    }

    
    @IBAction func unsplashPhotoPickerButton_onClick(_ sender: Any) {
        
        
        let config = Config()
        let picker = UnsplashPhotoPicker(configuration: config.unsplashConfig)
        picker.photoPickerDelegate = self
        present(picker, animated: true)
        
    }
    

 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "EffectsVC" {
            let effectsVC = segue.destination as! EffectsVC
            guard let finalURl = effectsVC.finalURl else{
                print("Url is empty")
                return
            }
            effectsVC.delegate = self
            passUrlBack(url: finalURl)
            
        }
    }

}





