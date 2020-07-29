//
//  FullReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class FullReflectionViewController: UIViewController, AVAudioRecorderDelegate {

    // MARK: - Global Variables
    // IBOutlet connections
    @IBOutlet weak var promptInspirationButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var dayRatingSlider: UISlider!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var targetExperienceLabel: UILabel!
    @IBOutlet weak var chooseExperienceButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var growButton: UIButton!
    
    // Recording variables
    var audioRecordingSession : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    
    /// This allows CoreData to have a defined context to operate upon when using the four main functions:
    /// Create, Retrieve, Update, Delete (CRUD).
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // String to rename Experience button
    var newTargetExperience : String = ""

    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.updateSentimentLabel()
        if let targetExperience = targetExperience {
            chooseExperienceButton.setTitle(targetExperience.name, for: .normal)
        }
        else
        {
            chooseExperienceButton.setTitle("Choose Experience", for: .normal)
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        promptInspirationButton.layer.cornerRadius = promptInspirationButton.frame.size.height/2
        chooseExperienceButton.layer.cornerRadius = chooseExperienceButton.frame.size.height/2
        cancelButton.layer.cornerRadius = cancelButton.frame.size.height/2
        growButton.layer.cornerRadius = growButton.frame.size.height/2
        print(targetExperience?.name)
        print(targetExperienceString)
        if let targetExperience = targetExperience {
            chooseExperienceButton.setTitle(targetExperience.name, for: .normal)
        }
        else
        {
            chooseExperienceButton.setTitle("Choose Experience", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if targetExperience != nil {
            chooseExperienceButton.setTitle(targetExperienceString, for: .normal)
        }
        else
        {
            chooseExperienceButton.setTitle("Choose Experience", for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if let targetExperience = targetExperience {
            chooseExperienceButton.setTitle(targetExperience.name, for: .normal)
        }
        else
        {
            chooseExperienceButton.setTitle("Choose Experience", for: .normal)
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        if (segue.identifier == "chooseExperienceSegueFromFullReflection")
//        {
//            let experienceVC = ExperiencesViewController()
//            experienceVC.delegate = self
//            present(experienceVC, animated: true)
//        }
//        // Pass the selected object to the new view controller.
//    }

    
    // MARK: - IBActions
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    // Works with CoreData to save locally
    @IBAction func onGrowButtonPressed(_ sender: Any) {
        let item = ReflectionEntry(context: self.context)
        print("Grow button pressed")
        print("Selected Exprience: ", targetExperience!)
        if let targetExperience = targetExperience {
            if let prompt = promptTextField.text {
                item.prompt = prompt
            }
            if let reflection = reflectionTextView.text {
                item.textReflection = reflection
            }
            if let keyword = keywordTextField.text {
                item.keyword = keyword
            }
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            let dateSaved = formatter.string(from: Date())
            item.date = dateSaved
            let moodLevel = dayRatingSlider.value
            item.sentimentLevel = moodLevel
            item.parentExperience = targetExperience
            item.userReflectionParent = currentUser
            targetExperience.parentUser = currentUser
            itemArray.append(item)
            saveItems()
            _ = self.dismiss(animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Incomplete Entry", message: "Please ensure you have a keyword and selected experience to add this reflection to. This helps us help you grow the right tree!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func onAudioButtonPressed(_ sender: Any) {
        if audioRecorder == nil {
            
            // Audio Recording object
            audioRecordingSession = AVAudioSession.sharedInstance()

            // User permission
            // IMPORTANT: ensure "Info.plist" has NSMicrophoneUsageDescription fulfilled
            do {
                try audioRecordingSession.setCategory(.playAndRecord, mode: .default)
                try audioRecordingSession.setActive(true)
                audioRecordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            
                        } else {
                            // failed to record!
                        }
                    }
                }
            } catch {
                // failed to record!
            }
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func onChooseExperienceButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "chooseExperienceSegueFromFullReflection", sender: self)
        choosingExperience = true
    }
    
    @IBAction func onDayRatingSliderChanged(_ sender: Any) {
        let level = dayRatingSlider.value
        updateSentimentLabel(with: level)
    }
    
    // MARK: - CoreData functions
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context in Full Reflection, with debug error: \(error)")
        }
        
        // self.tableView.reloadData()
    }
    
    // MARK: - UI Functions
    func updateSentimentLabel(with level: Float = 0)
    {
        if level > 80
        {
            self.sentimentLabel.text = "😇"
        }
        else if level > 40
        {
            self.sentimentLabel.text = "😀"
        }
        else if level > 10
        {
            self.sentimentLabel.text = "🙃"
        }
        else if level > -10
        {
            self.sentimentLabel.text = "🤨"
        }
        else if level > -40
        {
            self.sentimentLabel.text = "😕"
        }
        else if level > -80
        {
            self.sentimentLabel.text = "🥴"
        }
        else
        {
            self.sentimentLabel.text = "🤬"
        }
    }
    
    func updateUI() {
        chooseExperienceButton.setTitle(newTargetExperience, for: .normal)
    }
    
    // MARK: - Text Helper Functions
    
    
    // MARK: - Audio Helper Functions
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
//            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
//            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: - Video Helper Functions

}
