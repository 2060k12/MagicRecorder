//
//  HomeViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit
import AVFoundation
class HomeViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var listOfRecordings : [URL]!
    @IBOutlet weak var recordingsTableView: UITableView!
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var audioRecordingPermission : Bool!
    var isRecordin = false
    var isPlaying = false
    var meterTimer:Timer!
    
    var selectedIndexPath: IndexPath?


    
    // This runs before user is able to see the screen
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
        recordingsTableView.register(UINib(nibName: const.EachRecordingCell, bundle: nil), forCellReuseIdentifier: const.EachRecordingCellReuse)
        
    }
    
   
    
    
    // when record button ios pressed
    @IBAction func recordButton_onPressed(_ sender: UIButton) {
        setUpRecorder()
        audioRecorder.delegate = self

        audioRecorder.record()
        //        meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
    }
   
    // when stop button is pressed
    @IBAction func stopButton_onPressed(_ sender: UIButton) {
       
            audioRecorder.stop()
            print(audioRecorder.currentTime)
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

        // todo:: check permission first
        func setUpRecorder() {
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
    
    // for table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: const.EachRecordingCellReuse, for: indexPath) as! EachRecordingCell
        // Safely access the listOfRecordings array
           if indexPath.row < listOfRecordings.count {
               let recording = listOfRecordings[indexPath.row]
               cell.recordingLengthLabel.text = "0:00"
               cell.recordingNameLabel.text = recording.absoluteString
               cell.currentRecording = recording

           } else {
               // Handle the case where the index is out of bounds
               cell.recordingLengthLabel.text = "Unknown"
           }
        

        return cell
    }
    
    // changes the height of the selected row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
                   return 200 // Height when selected
               }
               return 50 // Initial height
    }
    
    
    
    // when any row is selected it updates "selectedIndexPath" variable
    // which then will be used to change the height of the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
             tableView.beginUpdates()
             tableView.endUpdates()
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
