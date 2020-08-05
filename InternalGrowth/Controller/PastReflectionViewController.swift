//
//  PastReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos
import CoreData

class PastReflectionViewController: UIViewController {
    
    // MARK: - Global Variables

    @IBOutlet weak var reflectionPromptLabel: UILabel!
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var editReflectionButton: UIButton!
    
    // Video Reflection outlets
    @IBOutlet weak var videoReflectionPlaybackVStackView: UIStackView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var videoTimeLabel: UILabel!
    @IBOutlet weak var videoProgressBar: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    // Video variables
    var playerItem: AVPlayerItem?
    let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    var duration: CMTime?
    var seconds: Float64?
    var timeObserverToken: Any?
    
    /// This allows CoreData to have a defined context to operate upon when using the four main functions:
    /// Create, Retrieve, Update, Delete (CRUD).
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
               self,
               selector: #selector(FullReflectionViewController.playerDidReachEndNotificationHandler(_:)),
               name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"),
               object: player?.currentItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Date formatter
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        // Updating views based on info
        reflectionPromptLabel.text = itemArray[selectedReflection].prompt
        keywordLabel.text = itemArray[selectedReflection].keyword
        dateTimeLabel.text = itemArray[selectedReflection].date
        
        // Formatting labels
        reflectionPromptLabel.numberOfLines = 0
        keywordLabel.numberOfLines = 0
        dateTimeLabel.numberOfLines = 0
        
        // Formatting buttons
        saveChangesButton.titleLabel?.numberOfLines = 0
        saveChangesButton.titleLabel?.textAlignment = .center
        editReflectionButton.titleLabel?.numberOfLines = 0
        editReflectionButton.titleLabel?.textAlignment = .center
        
        // show video if needed
        if (itemArray[selectedReflection].reflectionType == "text") {
            videoReflectionPlaybackVStackView.isHidden = true
            reflectionTextView.isHidden = false
            reflectionTextView.text = itemArray[selectedReflection].textReflection
        }
        else if (itemArray[selectedReflection].reflectionType == "video") {
            if let assetID = itemArray[selectedReflection].videoReflectionAssetIdentifier {
                videoReflectionPlaybackVStackView.isHidden = false
                reflectionTextView.isHidden = true
                loadAsset(identifier: assetID)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playButton.layer.cornerRadius = playButton.frame.height/2
        playButton.clipsToBounds = true
    }
    
    // MARK: - IBAction functions
    
    @IBAction func onPlayButtonPressed(_ sender: Any) {
        if player?.rate == 0 {
            player?.rate = 1.0
            updatePlayButtonTitle(isPlaying: true)
        } else {
            player?.pause()
            updatePlayButtonTitle(isPlaying: false)
        }
    }
    
    @IBAction func onEditButtonPressed(_ sender: Any) {
        reflectionTextView.isEditable = true
        editReflectionButton.isEnabled = false
        saveChangesButton.isEnabled = true
        editButtonItem.isEnabled = false
    }
    
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        reflectionTextView.isEditable = false
        editReflectionButton.isEnabled = true
        saveChangesButton.isEnabled = false
        editButtonItem.isEnabled = true
        
        itemArray[selectedReflection].prompt = reflectionPromptLabel.text
        itemArray[selectedReflection].keyword = keywordLabel.text
        itemArray[selectedReflection].textReflection = reflectionTextView.text
        saveItems()
    }
    
    @IBAction func onDeleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Deleting Reflection", message: "Are you sure you want to delete this reflection?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.context.delete(itemArray[selectedReflection])
            itemArray.remove(at: selectedReflection)
            self.saveItems()
            self.performSegue(withIdentifier: "unwindToTimeline", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Video Playback
    
    // Helper @objc functions
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
           playButton.setTitle("Pause", for: .normal)
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
            playButton.setTitle("Pause", for: .normal)
            playButton.backgroundColor = .systemRed
        } else {
            playButton.setTitle("Play", for: .normal)
            playButton.backgroundColor = .systemBlue
        }
    }

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
                self.playerLayer.frame = self.videoContainerView.bounds
                self.playerLayer.videoGravity = .resizeAspect
                self.videoContainerView.layer.addSublayer(self.playerLayer)
                
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
