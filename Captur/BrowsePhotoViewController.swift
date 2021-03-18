//
//  BrowsePhotoViewController.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/02/05.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import Vision

class BrowsePhotoViewController : UIViewController{
    
    var allPhotos : PHFetchResult<PHAsset>!
    var smartAlbums : PHFetchResult<PHAssetCollection>!
    var userCollections : PHFetchResult<PHCollection>!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        photoSetup()
    }
    
    func photoSetup(){
        PHPhotoLibrary.shared().register(self)
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    }
    
    func displayAssets(){
        
    }
    
}

extension BrowsePhotoViewController : PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {}
}
