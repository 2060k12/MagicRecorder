//
//  HomeViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit
import AVFoundation
class HomeViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listOfRecordings = getAlItems(url: savedDirectory())

        Task{
            do{
                 try await checkRecordPermission()
            }catch{
                print("Error")
            }
        }
        
        
        recordingsTableView.reloadData()
        recordingsTableView.dataSource = self
        recordingsTableView.delegate = self
        
    }
    
    var listOfRecordings : [URL]!
    @IBOutlet weak var recordingsTableView: UITableView!
    
    
    // for table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listOfRecordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: const.EachRecordingCell, for: indexPath) as! EachRecordingCell
        // Safely access the listOfRecordings array
           if indexPath.row < listOfRecordings.count {
               let recording = listOfRecordings[indexPath.row]
               cell.recordingLengthLabel.text = recording.absoluteString
           } else {
               // Handle the case where the index is out of bounds
               cell.recordingLengthLabel.text = "Unknown"
           }

        return cell
    }
    
    
    func savedDirectory() ->URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
    }
    
    func getAlItems (url : URL) -> [URL] {
        let fileManager = FileManager.default
        do {
            let items = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        return items
        }
        catch {
            print("\(error.localizedDescription)")
            return []
        }
    }
    

  
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var audioRecordingPermission : Bool!
    var isRecordin = false
    var isPlaying = false
    var meterTimer:Timer!

   
    
    // when record button ios pressed
    @IBAction func recordButton_onPressed(_ sender: UIButton) {
        setUpRecorder()
        audioRecorder.record()
        //        meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
    }
   
    // when stop button is pressed
    @IBAction func stopButton_onPressed(_ sender: UIButton) {
       
            audioRecorder.stop()
            audioRecorder = nil
            print("Successfully done")
            recordingsTableView.reloadData()
        
    }
    
    
    // checks permission to record audio,
    // If the application does't have permission for the first time
    // it will also ask for permission
    func checkRecordPermission() async throws {
        
        let session = AVAudioApplication.shared
        
        switch session.recordPermission {
        case .undetermined:
            AVAudioApplication.requestRecordPermission{ granted in
                if(granted) {
                    print("Permission has been Granted")
                    
                }
                else {
                    print("Permission has been Granted")
                }
            }
        case .denied:
            audioRecordingPermission = false
            print("Something went wrong")
            
        case .granted:
            audioRecordingPermission = true
            
        @unknown default:
            fatalError("Something went wrong")
        }
    }
        
        
        
        func savingDirectory() ->URL {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = path[0]
            return documentDirectory
        }
        
        func getFileUrl () -> URL {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = formatter.string(from: Date())
            let fileName = dateString
            let filePath = savingDirectory().appendingPathComponent(fileName, conformingTo: .mpeg4Audio)
            print (filePath)
            return filePath
        }

        
        func setUpRecorder() {
//            if(audioRecordingPermission) {
                let session = AVAudioSession.sharedInstance()
                
                do {
                    try session.setActive(true)
                    // audio setting of recorded audio
                    let setting  = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                      AVSampleRateKey: 44100,
                                      AVNumberOfChannelsKey: 2,
                                      AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                    ]
                    audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: setting)
                    audioRecorder.delegate = self
                    audioRecorder.isMeteringEnabled = true
                    audioRecorder.prepareToRecord()
                    
                }catch {
                    print ("\(error.localizedDescription)")
                }
//            }
//            else {
//                print("NO access to microphone")
//            }
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
