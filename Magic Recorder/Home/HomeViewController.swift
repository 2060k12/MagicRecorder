//
//  HomeViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 26/7/2024.
//

import UIKit
import AVFoundation
class HomeViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // working with Realm Db
    // it is an offile database which holds all of our reocrdings details
    let db = OfflineRepository()
    
    var listOfRecordings : [Recording]!
    @IBOutlet weak var recordingsTableView: UITableView!
    
    var recorder : AVAudioRecorder!
    var player : AVAudioPlayer!
    var timer: Timer?
    var url:URL?
    var audioRecordingPermission : Bool!
    var isRecordin = false
    var isPlaying = false
    var meterTimer:Timer!
    
    var selectedIndexPath: IndexPath?

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    // This runs before user is able to see the screen
    override func viewDidLoad() {
        // initially hide and disable stop button
        stopButton.isHidden = true
        stopButton.isEnabled = false
        super.viewDidLoad()
        
       loadRecordings()

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
        recordButton.isHidden = true
        recordButton.isEnabled = false
        
        stopButton.isHidden = false
        stopButton.isEnabled = true
        
        setUpRecorder()
        recorder.delegate = self

    }
   
    // when stop button is pressed
    @IBAction func stopButton_onPressed(_ sender: UIButton) {
            recordButton.isHidden = false
            recordButton.isEnabled = true
        
            stopButton.isHidden = true
            stopButton.isEnabled = false
        
            recorder.stop()
            print(recorder.currentTime)
            recorder = nil
            print("Successfully done")
            loadRecordings()
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
        
        func getFileUrl () ->( URL, String ) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = formatter.string(from: Date())
            let fileName = dateString
            let filePath = savingDirectory().appendingPathComponent(fileName, conformingTo: .mpeg4Audio)
            print (filePath)
            return (filePath, fileName)
        }

        // todo:: check permission first
        func setUpRecorder() {
                let session = AVAudioSession.sharedInstance()
                
            try? session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            let filePath = getFileUrl().0
            var recordSetting : [AnyHashable: Any] = [
                AVFormatIDKey : kAudioFormatMPEG4AAC,
                AVSampleRateKey :  1600.0,
                AVNumberOfChannelsKey : 1,
            ]
            
            let audioRecorder = try? AVAudioRecorder(url: filePath, settings: (recordSetting as? [String : Any] ?? [:]))
            print(filePath)
            
            // Creating an instance of recording class to be stored in RealmDB
            let recording = Recording(name: getFileUrl().1, savedPath: filePath.absoluteString)
            // add the current recording path and name into database
            db.insertRecording(recording: recording)
            db.getPathOfRealmDB() // for debgging purpose
            
            self.recorder = audioRecorder
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = true
            self.recorder.prepareToRecord()
            self.recorder.record()
            
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
    
    // gets all recordings from realm db
    func getAllRecordings() -> [Recording] {
        
        var recordings = [Recording]()
        db.getAllRecordings().forEach {
            recording in
            recordings.append(recording)
        }
        return recordings
    }
    
//    
//    func loadRecordings() {
//            listOfRecordings = getAlItems(url: savingDirectory())
//            recordingsTableView.reloadData()
//        }
    
    
    
    func loadRecordings() {
            listOfRecordings = getAllRecordings()
            recordingsTableView.reloadData()
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
               cell.recordingNameLabel.text = recording.name
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
