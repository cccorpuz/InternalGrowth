//
//  FullReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import AVFoundation

class FullReflectionViewController: UIViewController, AVAudioRecorderDelegate {

    // MARK: - Global Variables
    // IBOutlet connections
    @IBOutlet weak var promptInspirationButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    
    // Recording variables
    var audioRecordingSession : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        promptInspirationButton.layer.cornerRadius = promptInspirationButton.frame.size.height/2;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBActions
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onGrowButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
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
