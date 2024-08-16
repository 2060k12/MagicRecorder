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
    let profileRepo = ProfileRepository()
    
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
    
    var deselectRowAt: IndexPath?
    var selectedIndexPath: IndexPath?
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
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
        recordingsTableView.register(UINib(nibName: Const.EachRecordingCell, bundle: nil), forCellReuseIdentifier: Const.EachRecordingCellReuse)
        
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
        let filePath = savingDirectory().appendingPathComponent(fileName, conformingTo: .wav)
        print (filePath)
        return (filePath, fileName)
    }
    
    // todo:: check permission first
    func setUpRecorder() {
        let session = AVAudioSession.sharedInstance()
        
        try? session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        let filePath = getFileUrl().0 // geting the first return value
        let recordSetting: [AnyHashable: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM, // Use Linear PCM for WAV
                   AVSampleRateKey: 44100.0,             // Common sample rate
                   AVNumberOfChannelsKey: 2,             // Stereo
                   AVLinearPCMBitDepthKey: 16,           // 16-bit depth is widely supported
                   AVLinearPCMIsBigEndianKey: false,     // Little-endian format
                   AVLinearPCMIsFloatKey: false          // Integer samples
        ]

        
        let audioRecorder = try? AVAudioRecorder(url: filePath, settings: (recordSetting as? [String : Any] ?? [:]))
        print(filePath)
        
        // Creating an instance of recording class to be stored in RealmDB
        let recording = Recording(name: getFileUrl().1, savedPath: filePath.absoluteString)
        // add the current recording path and name into database
        db.insertRecording(recording: recording)
        
        
//        db.getPathOfRealmDB() // for debgging purpose
        
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

    func loadRecordings() {
        listOfRecordings = getAllRecordings()
        recordingsTableView.reloadData()
    }
   
    // for table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.EachRecordingCellReuse, for: indexPath) as! EachRecordingCell
        
        cell.currentScreen = Const.HomeScreen
        // Safely access the listOfRecordings array
        if indexPath.row < listOfRecordings.count {
            let recording = listOfRecordings[indexPath.row]
            
            do {
                player = try AVAudioPlayer(contentsOf: savedDirectory().appendingPathComponent(recording.name, conformingTo: .wav))
                
            }catch {
                print(error.localizedDescription)
            }
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad

            if let player = player {
                if let formattedDuration = formatter.string(from: player.duration) {
                    cell.recordingLengthLabel.text = formattedDuration
                }
            }
  
            cell.recordingNameLabel.text = recording.name
            cell.currentRecording = recording
            cell.editButton.addTarget(self, action: #selector(goToEditScreen) , for: .touchUpInside)

            
            profileRepo.checkIfInTheCloud(recording: recording) { isInDb in
                if isInDb {
                    cell.syncOnOff.isOn = true
                }
                else {
                    cell.syncOnOff.isOn = false
                }
            }
            
        } else {
            // Handle the case where the index is out of bounds
            cell.recordingLengthLabel.text = "Unknown"
        }
        
        
        return cell
    }
    
    @objc func goToEditScreen(){
        if let  selectedIndexPath {

        if let destinationVc = storyboard?.instantiateViewController(withIdentifier: Const.EditScreenVC) as? EditScreenVC {
                destinationVc.recording = listOfRecordings[selectedIndexPath.row]
                
                print("working")
                self.navigationController?.pushViewController(destinationVc, animated: true)
            }
        }
     
        
    }
    // changes the height of the selected row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath  {
            return 200 // Height when selected
        }
    
        return 50 // Initial height
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        deselectRowAt = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    // when any row is selected it updates "selectedIndexPath" variable
    // which then will be used to change the height of the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
   
    
}
