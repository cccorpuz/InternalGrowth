//
//  EditVideoViewController.swift
//  InternalGrowth
//
//  Created by Claire Schweikert on 7/28/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import Photos

class EditVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    
      @IBOutlet var activityMonitor: UIActivityIndicatorView!
      
      func savedPhotosAvailable() -> Bool {
        guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return true }
        
        let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return false
      }
      
      @IBAction func loadAssetOne(_ sender: AnyObject) {
        if savedPhotosAvailable() {
          loadingAssetOne = true
          VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
      }
      
      @IBAction func loadAssetTwo(_ sender: AnyObject) {
        if savedPhotosAvailable() {
          loadingAssetOne = false
          VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
      }
      
      @IBAction func loadAudio(_ sender: AnyObject) {
        let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
        mediaPickerController.delegate = self
        mediaPickerController.prompt = "Select Audio"
        present(mediaPickerController, animated: true, completion: nil)      }
        
      @IBAction func merge(_ sender: AnyObject) {
        guard
          let firstAsset = firstAsset,
          let secondAsset = secondAsset
          else {
            return
        }

        activityMonitor.startAnimating()

        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()

        // 2 - Create two video tracks
        guard
          let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                          preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
          else {
            return
        }
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: firstAsset.duration),
                                         of: firstAsset.tracks(withMediaType: AVMediaType.video)[0],
                                         at: CMTime.zero)
        } catch {
          print("Failed to load first track")
          return
        }

        guard
          let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
          else {
            return
        }
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: secondAsset.duration),
                                          of: secondAsset.tracks(withMediaType: AVMediaType.video)[0],
                                          at: firstAsset.duration)
        } catch {
          print("Failed to load second track")
          return
        }

        // 3 - Audio track
        if let loadedAudioAsset = audioAsset {
          let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
          do {
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                            duration: CMTimeAdd(firstAsset.duration,
                                                                      secondAsset.duration)),
                                            of: loadedAudioAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                                            at: CMTime.zero)
          } catch {
            print("Failed to load Audio track")
          }
        }

        // 4 - Get path
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
          return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")

        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else {
          return
        }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true

        // 6 - Perform the Export
        exporter.exportAsynchronously() {
          DispatchQueue.main.async {
            self.exportDidFinish(exporter)
          }
        }
      }
    
    func exportDidFinish(_ session: AVAssetExportSession) {
      
      // Cleanup assets
      activityMonitor.stopAnimating()
      firstAsset = nil
      secondAsset = nil
      audioAsset = nil
      
      guard
        session.status == AVAssetExportSession.Status.completed,
        let outputURL = session.outputURL
        else {
          return
      }
      
      let saveVideoToPhotos = {
        PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
        }) { saved, error in
          let success = saved && (error == nil)
          let title = success ? "Success" : "Error"
          let message = success ? "Video saved" : "Failed to save video"
          
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
          self.present(alert, animated: true, completion: nil)
        }
      }
      
      // Ensure permission to access Photo Library
      if PHPhotoLibrary.authorizationStatus() != .authorized {
        PHPhotoLibrary.requestAuthorization { status in
          if status == .authorized {
            saveVideoToPhotos()
          }
        }
      } else {
        saveVideoToPhotos()
      }
    }
      
    }

    extension EditVideoViewController: UIImagePickerControllerDelegate {
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType.rawValue] as? String,
          mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL
          else { return }
        
        let avAsset = AVAsset(url: url)
        var message = ""
        if loadingAssetOne {
          message = "Video one loaded"
          firstAsset = avAsset
        } else {
          message = "Video two loaded"
          secondAsset = avAsset
        }
        let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
      }
      
    }

    extension EditVideoViewController: UINavigationControllerDelegate {
      
    }

    extension EditVideoViewController: MPMediaPickerControllerDelegate {
      func mediaPicker(_ mediaPicker: MPMediaPickerController,
                       didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        dismiss(animated: true) {
          let selectedSongs = mediaItemCollection.items
          guard let song = selectedSongs.first else { return }
          
          let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
          self.audioAsset = (url == nil) ? nil : AVAsset(url: url!)
          let title = (url == nil) ? "Asset Not Available" : "Asset Loaded"
          let message = (url == nil) ? "Audio Not Loaded" : "Audio Loaded"
          
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
          self.present(alert, animated: true, completion: nil)
        }
      }

      func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
      }
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
