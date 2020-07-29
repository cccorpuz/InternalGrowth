//
//  FullReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import MobileCoreServices
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
    
    // MARK: - IBActions
    
    @IBAction func onDayRatingSliderChanged(_ sender: Any) {
        let level = dayRatingSlider.value
        updateSentimentLabel(with: level)
    }
    
    @IBAction func onTextButtonPressed(_ sender: Any) {
        reflectionMedia = "text"
    }
    @IBAction func onAudioButtonPressed(_ sender: Any) {
        reflectionMedia = "audio"
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
    
    @IBAction func onVideoButtonPressed(_ sender: Any) {
        reflectionMedia = "video"
        let alert = UIAlertController(title: "Visual Reflection", message: "Select a source for this reflection:", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Your Videos", style: .default, handler: { (action) in
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }))
        alert.addAction(UIAlertAction(title: "New Video Reflection", style: .default, handler: { (action) in
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func onChooseExperienceButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "chooseExperienceSegueFromFullReflection", sender: self)
        choosingExperience = true
    }
    
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    // Works with CoreData to save locally
    @IBAction func onGrowButtonPressed(_ sender: Any) {
        let item = ReflectionEntry(context: self.context)
        print("Grow button pressed")
        print("Selected Exprience: ", targetExperience)
        if let targetExperience = targetExperience, let keyword = keywordTextField.text {
            if let prompt = promptTextField.text {
                item.prompt = prompt
            }
            if let reflection = reflectionTextView.text {
                item.textReflection = reflection
            }
            
            item.keyword = keyword
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            let dateSaved = formatter.string(from: Date())
            item.date = dateSaved
            let moodLevel = dayRatingSlider.value
            item.sentimentLevel = moodLevel
            item.reflectionType = reflectionMedia
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
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
         let title = (error == nil) ? "Success" : "Error"
         let message = (error == nil) ? "Video was saved" : "Video failed to save"
         
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
         present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension FullReflectionViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    dismiss(animated: true, completion: nil)

        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
        mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
        UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        else { return }

        // Handle a movie capture
        print("Handling movie")
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
        videoURL = url.path
    }
}

// MARK: - UINavigationControllerDelegate

extension FullReflectionViewController: UINavigationControllerDelegate {
    
}
