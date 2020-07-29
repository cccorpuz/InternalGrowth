//
//  VideoHelper.swift
//  InternalGrowth
//
//  Created by Claire Schweikert on 7/28/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation
import MobileCoreServices
import AVFoundation

class VideoHelper {
  
  static func startMediaBrowser(delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, sourceType: UIImagePickerControllerSourceType) {
    guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
    
    let mediaUI = UIImagePickerController()
    mediaUI.sourceType = sourceType
    mediaUI.mediaTypes = [kUTTypeMovie as String]
    mediaUI.allowsEditing = true
    mediaUI.delegate = delegate
    delegate.present(mediaUI, animated: true, completion: nil)
  }

  
}
