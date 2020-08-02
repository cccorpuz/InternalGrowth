//
//  VideoReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/31/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class VideoReflectionViewController: UIViewController {
    
    // MARK: - Global Variables
    

    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    } // end viewDidLoad()
    
    override func viewWillAppear(_ animated: Bool) {
//        setupUI()
    } // end viewWillAppear()
        
    // MARK: - Setup Functions
    
    func setupUI() {
        getLatestAsset(for: .video)
        if let assetID = assetIdentifier {
            loadAsset(identifier: assetID)
        } else {
            print("PHAsset Identifier was nil")
        }
    } // end SetupUI()
    
    // MARK: - PHAsset functions
    
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
            guard let avAsset = avAsset else { fatalError("AVAsset is nil") }
            let playerItem = AVPlayerItem(asset: avAsset)
            let player = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            playerLayer.videoGravity = .resizeAspect
            DispatchQueue.main.async {
                self.view.layer.addSublayer(playerLayer)
                player.play()
            }
        }
    } // end loadVideo()
} // End VideoReflectionViewController.swift
