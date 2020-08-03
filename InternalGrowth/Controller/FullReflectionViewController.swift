//
//  FullReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import CoreData
import Photos

var reflectionFrame : CGRect?

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
    
    // These contain the views that pertain to the different ways of making reflections
    @IBOutlet weak var reflectionStackView: UIStackView!
    @IBOutlet weak var reflectionMediaVStackView: UIStackView!
    @IBOutlet weak var reflectionMediaContainerView: UIView!
    @IBOutlet weak var videoProgressBar: UISlider!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var videoTimeLabel: UILabel!
    
    // Video variables
    var playerItem: AVPlayerItem?
    let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    var duration: CMTime?
    var seconds: Float64?
    var timeObserverToken: Any?
    
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
        // default
        reflectionMedia = "text"
        
        // pre-load
        getLatestAsset(for: .video)
        if let assetID = assetIdentifier {
            loadAsset(identifier: assetID)
        }
        
        // Observer to reset time on video
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(FullReflectionViewController.playerDidReachEndNotificationHandler(_:)),
        name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"),
        object: player?.currentItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        promptInspirationButton.layer.cornerRadius = promptInspirationButton.frame.size.height/2
        chooseExperienceButton.layer.cornerRadius = chooseExperienceButton.frame.size.height/2
        cancelButton.layer.cornerRadius = cancelButton.frame.size.height/2
        growButton.layer.cornerRadius = growButton.frame.size.height/2
        reflectionFrame = reflectionTextView.bounds
        assetIdentifier = nil
        if let targetExperience = targetExperience {
            chooseExperienceButton.setTitle(targetExperience.name, for: .normal)
        }
        else
        {
            chooseExperienceButton.setTitle("Choose Experience", for: .normal)
        }
        switch reflectionMedia {
        case "text":
            reflectionTextView.isHidden = false
        case "audio":
            reflectionTextView.isHidden = true
            reflectionTextView.text = ""
        case "video":
            reflectionTextView.isHidden = true
            reflectionTextView.text = ""
            reflectionMediaContainerView.isHidden = false
            getLatestAsset(for: .video)
            if let assetID = assetIdentifier {
                loadAsset(identifier: assetID)
            }
        default:
            reflectionTextView.isHidden = false
            reflectionTextView.text = ""
        }
        highlightReflectionButton()
    }

    // MARK: - IBActions [top-down]
    
    @IBAction func onDayRatingSliderChanged(_ sender: Any) {
        let level = dayRatingSlider.value
        updateSentimentLabel(with: level)
    }
    
    @IBAction func onPromptInspirationButtonPressed(_ sender: Any) {
        
    }
    @IBAction func onTextButtonPressed(_ sender: Any) {
        reflectionMedia = "text"
        highlightReflectionButton()
        reflectionMediaVStackView.isHidden = true
        print(reflectionMedia!)
        reflectionTextView.isHidden = false
    }
    @IBAction func onAudioButtonPressed(_ sender: Any) {
        reflectionMedia = "audio"
        highlightReflectionButton()
        reflectionMediaVStackView.isHidden = true
        print(reflectionMedia!)
        reflectionTextView.isHidden = true
        reflectionTextView.text = ""
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
        highlightReflectionButton()
        playVideoButton.layer.cornerRadius = playVideoButton.frame.height/2
        playVideoButton.clipsToBounds = true
        reflectionMediaVStackView.isHidden = false
        print(reflectionMedia!)
        reflectionTextView.isHidden = true
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
    
    @IBAction func onPlayButtonPressed(_ sender: Any) {
        if player?.rate == 0 {
            player?.rate = 1.0
            updatePlayButtonTitle(isPlaying: true)
        } else {
            player?.pause()
            updatePlayButtonTitle(isPlaying: false)
        }
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
        print("Selected Exprience: ", targetExperience as Any)
        if let targetExperience = targetExperience, let keyword = keywordTextField.text {
            if let prompt = promptTextField.text {
                item.prompt = prompt
            }
            item.keyword = keyword
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            let dateSaved = formatter.string(from: Date())
            item.date = dateSaved
            let moodLevel = dayRatingSlider.value
            item.sentimentLevel = moodLevel
            item.reflectionType = reflectionMedia
            if let reflection = reflectionTextView.text {
                item.textReflection = reflection
            }
            if let assetID = assetIdentifier {
                item.videoReflectionAssetIdentifier = assetID
            }
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
        if level > 80 {
            self.sentimentLabel.text = "😇"
        } else if level > 40 {
            self.sentimentLabel.text = "😀"
        } else if level > 10 {
            self.sentimentLabel.text = "🙃"
        } else if level > -10 {
            self.sentimentLabel.text = "🤨"
        } else if level > -40 {
            self.sentimentLabel.text = "😕"
        } else if level > -80 {
            self.sentimentLabel.text = "🥴"
        } else {
            self.sentimentLabel.text = "🤬"
        }
    }
    
    func highlightReflectionButton() {
        switch reflectionMedia {
        case "text":
            textButton.backgroundColor = .white
            audioButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
            videoButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
        case "audio":
            textButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
            audioButton.backgroundColor = .white
            videoButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
        case "video":
            textButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
            audioButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
            videoButton.backgroundColor = .white
        default:
            textButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
            audioButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
            videoButton.backgroundColor = UIColor.init(red: CGFloat(117.0/255.0), green: CGFloat(195.0/255.0), blue: CGFloat(234.0/255.0), alpha: 1.0)
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
        getLatestAsset(for: .video)
        if let assetID = assetIdentifier {
            loadAsset(identifier: assetID)
        }
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved to your Photo Library" : "Video failed to save to your Photo Library, try again"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    } // end video()
    
    @objc func playerDidReachEndNotificationHandler(_ notification: Notification) {
        // 1
        guard let playerItem = notification.object as? AVPlayerItem else { return }

        // 2
        playerItem.seek(to: .zero, completionHandler: nil)

        // 3
        if player?.actionAtItemEnd == .pause {
            player?.pause()
            updatePlayButtonTitle(isPlaying: false)
            videoProgressBar.value = 0
        }
    } // end playerDidReachEndNotificationHandler()
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Double = Double(playbackSlider.value)
        let targetTime : CMTime = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
            playVideoButton.setTitle("Pause", for: .normal)
        }
    } // end playbackSliderValueChanged
    
    // MARK: Update video accessories
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.20, preferredTimescale: timeScale)

        timeObserverToken = player?
            .addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            // update player transport UI
                let timeProgress = Float(CMTimeGetSeconds(time))
                self?.videoProgressBar.value = timeProgress
                var hours : Int { Int(timeProgress / 3600) }
                var minutes : Int { Int(timeProgress.truncatingRemainder(dividingBy: 3600) / 60) }
                var seconds : Int { Int(timeProgress.truncatingRemainder(dividingBy: 60)) }
                var positionalTime : String {
                    return hours > 0 ?
                        String(format: "%d:%02d:%02d",
                    hours, minutes, seconds) :
                        String(format: "%02d:%02d",
                    minutes, seconds)
                }
                    self?.videoTimeLabel.text = positionalTime
        }
    } // end addPeriodicTimeObserver()

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    } // end removePeriodicTimeObserver()
    
    func updatePlayButtonTitle(isPlaying: Bool) {
        if isPlaying {
            playVideoButton.setTitle("Pause", for: .normal)
            playVideoButton.backgroundColor = .systemRed
            playVideoButton.layer.cornerRadius = playVideoButton.frame.height/2
            playVideoButton.layer.shadowColor = UIColor.darkGray.cgColor
            playVideoButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            playVideoButton.layer.shadowOpacity = 1.0
            playVideoButton.layer.masksToBounds = false
        } else {
            playVideoButton.setTitle("Play", for: .normal)
            playVideoButton.backgroundColor = .systemBlue
            playVideoButton.layer.cornerRadius = playVideoButton.frame.height/2
            playVideoButton.layer.shadowColor = UIColor.darkGray.cgColor
            playVideoButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            playVideoButton.layer.shadowOpacity = 1.0
            playVideoButton.layer.masksToBounds = false
        }
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
        print("Saving movie")
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
        getLatestAsset(for: .video)
        loadAsset(identifier: assetIdentifier!)
    }
}

// MARK: - UINavigationControllerDelegate

extension FullReflectionViewController: UINavigationControllerDelegate {
    
}

// MARK: - Video Playback Setup
extension FullReflectionViewController {
    
    /* -----Uncomment if using for adding containers programatically--------
    // add child viewcontroller
    func add(_ child: UIViewController) {
        addChild(child)
        reflectionStackView.addArrangedSubview(child.view)
        child.didMove(toParent: self)
    }

    // add child viewcontroller
    func remove(_ child: UIViewController) {
        guard child.parent != nil else {
            return
        }

        child.willMove(toParent: nil)
        reflectionStackView.removeArrangedSubview(child.view)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    -------------------------------------------------------------------------*/
    
    // MARK: Asset Loading
    func getLatestAsset(for type: PHAssetMediaType) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate",
        ascending: false)]
        fetchOptions.fetchLimit = 2
        let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: type, options: fetchOptions)
        guard let asset = fetchResult.firstObject else { fatalError("Unable to retrieve media") }
        assetIdentifier = asset.localIdentifier
        print(assetIdentifier ?? "Asset not found")
        
    } // end getLatestAsset()
    
    func loadAsset(identifier: String) {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else {
            fatalError("No asset found with identifier \(identifier)")
        }
        print(asset.localIdentifier)
        if asset.mediaType == .image {
            loadImage(asset: asset)
        }
        else if asset.mediaType == .video {
            loadVideo(asset: asset)
        }
    } // end loadAsset()
    
    func loadImage(asset: PHAsset) {
        PHImageManager().requestImageDataAndOrientation(for: asset, options: nil) { (data, string, orientation, userInfo) in
            guard let data = data else { fatalError("Image Data is nil") }
            DispatchQueue.main.async {
                let imageView = UIImageView()
                imageView.image = UIImage(data: data)
            }
        }
    } // end loadImage()
    
    func loadVideo(asset: PHAsset) {
        PHImageManager().requestAVAsset(forVideo: asset, options: nil) { (avAsset, audioMix, userInfo) in
            DispatchQueue.main.async {
                guard let avAsset = avAsset else { fatalError("AVAsset is nil") }
                self.playerItem = AVPlayerItem(asset: avAsset)
                self.player = AVPlayer(playerItem: self.playerItem)
                self.playerLayer.player = self.player
                self.player?.actionAtItemEnd = .pause
                self.playerLayer.frame = self.reflectionMediaContainerView.bounds
                self.playerLayer.videoGravity = .resizeAspect
                self.reflectionMediaContainerView.layer.addSublayer(self.playerLayer)
                
                // Setup accessories to video
                self.videoProgressBar.minimumValue = 0
                self.duration = self.playerItem?.asset.duration
                self.seconds = CMTimeGetSeconds(self.duration!)
                self.videoProgressBar.maximumValue = Float(self.seconds!)
                self.videoProgressBar.isContinuous = true
                self.videoProgressBar.addTarget(self, action: #selector(self.playbackSliderValueChanged), for: .valueChanged)
                self.addPeriodicTimeObserver()
            }
        }
    } // end loadVideo()
}
