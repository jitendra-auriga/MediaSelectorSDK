//
//  MediaPickerManager.swift
//  MediaSelector
//
//  Created by mac on 2022-08-22.
//


import Foundation
import Photos
import UIKit
//import CropViewController

public class MediaPickerManager: NSObject {
        
    public static let shared = MediaPickerManager()
    
    private var picker = UIImagePickerController()
    private var alertType = UIAlertController(title: "Select media type", message: nil, preferredStyle: .actionSheet)
    private var alertFrom = UIAlertController(title: "Select media from", message: nil, preferredStyle: .actionSheet)

    private var viewController: UIViewController = UIViewController()
    private var pickedMediaCallback : ((UIImage, URL?) -> ())?
    private var allowCroping = false
    private var isSelectingVideo = false
    private var selectionMediaType: MediaType?
    private var mediaSource: Source?
    private var allowSettingsNavigation = false

    private override init(){
        super.init()
    }
        
    public func pickMedia(_ viewController: UIViewController, mediaType: MediaType? = nil, source: Source? = nil, allowCrop: Bool = false, allowSettingsNavigation: Bool = false, _ callback: @escaping ((UIImage, URL?) -> ())) {
        
        picker.delegate = self
        pickedMediaCallback = callback
        self.viewController = viewController
        self.allowCroping = allowCrop
        self.selectionMediaType = mediaType
        self.mediaSource = source
        self.allowSettingsNavigation = allowSettingsNavigation
        
        alertType = UIAlertController(title: "Select media type", message: nil, preferredStyle: .actionSheet)
        
        if mediaType == nil {
            let cameraAction = UIAlertAction(title: "Image", style: .default){
                UIAlertAction in
                DispatchQueue.main.async {
                    self.pickImage()
                }
            }
            let galleryAction = UIAlertAction(title: "Video", style: .default){
                UIAlertAction in
                self.isSelectingVideo = true
                DispatchQueue.main.async {
                    self.pickVideo()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
                UIAlertAction in
            }

            // Add the actions
            alertType.addAction(cameraAction)
            alertType.addAction(galleryAction)
            alertType.addAction(cancelAction)
            DispatchQueue.main.async {
                self.alertType.popoverPresentationController?.sourceView = self.viewController.view
                viewController.present(self.alertType, animated: true, completion: nil)
            }
        }
        else if mediaType == .image {
            DispatchQueue.main.async {
                self.pickImage()
            }
        }
        else if mediaType == .video {
            DispatchQueue.main.async {
                self.pickVideo()
            }
        }
        
    }
    
    
    func pickImage() {
        if mediaSource == nil {

            alertFrom = UIAlertController(title: "Select Image from", message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default){
                UIAlertAction in
                self.openCamera()
            }
            let galleryAction = UIAlertAction(title: "Gallery", style: .default){
                UIAlertAction in
                self.openGallery()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
                UIAlertAction in
            }

            // Add the actions
            alertFrom.addAction(cameraAction)
            alertFrom.addAction(galleryAction)
            alertFrom.addAction(cancelAction)
            
            DispatchQueue.main.async {
                self.alertFrom.popoverPresentationController?.sourceView = self.viewController.view
                self.viewController.present(self.alertFrom, animated: true, completion: nil)
            }
        }
        else if mediaSource == .camera {
            self.openCamera()
        }
        else if mediaSource == .gallery {
            self.openGallery()
        }
    }
        
    func pickVideo() {
        if mediaSource == nil {
            alertFrom = UIAlertController(title: "Select Video from", message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default){
                UIAlertAction in
                self.openVideoCamera()
            }
            let galleryAction = UIAlertAction(title: "Gallery", style: .default){
                UIAlertAction in
                self.openVideoGallery()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
                UIAlertAction in
            }

            // Add the actions
            alertFrom.addAction(cameraAction)
            alertFrom.addAction(galleryAction)
            alertFrom.addAction(cancelAction)
            DispatchQueue.main.async {
                self.alertFrom.popoverPresentationController?.sourceView = self.viewController.view
                self.viewController.present(self.alertFrom, animated: true, completion: nil)
            }
        }
        else if mediaSource == .camera {
            self.openVideoCamera()
        }
        else if mediaSource == .gallery {
            self.openVideoGallery()
        }
        
    }
    
    func openCamera() {
        alertFrom.dismiss(animated: true, completion: nil)
        CheckPermissions.shared.checkCameraAccess(isAuthorized: { isAuthorized in
            if isAuthorized {
                if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
                    DispatchQueue.main.async {
                        self.picker.sourceType = .camera
                        self.picker.mediaTypes = ["public.image"]
                        self.viewController.present(self.picker, animated: true, completion: nil)
                    }
                } else {
                    //showAlert(msg: "You don't have camera", buttonTitle: [Messages.general.ok])
                    print("You don't have camera")
                }
            }
            else {
                if self.allowSettingsNavigation {
                    AppSettings().askUserToOpenSettings(msg: MediaAccessMessages.needAccessOf.camera, viewController: self.viewController)
                }
            }
        })
    }
    
    func openGallery(){
        CheckPermissions.shared.checkPhotoLibraryPermission { isAuthorised in
            if isAuthorised {
                DispatchQueue.main.async {
                    self.picker.sourceType = .photoLibrary
                    self.picker.mediaTypes = ["public.image"]
                    self.viewController.present(self.picker, animated: true, completion: nil)
                }
            }
            else {
                if self.allowSettingsNavigation {
                    AppSettings().askUserToOpenSettings(msg: MediaAccessMessages.needAccessOf.photos, viewController: self.viewController)
                }
            }
        }
    }
    
    func openVideoCamera() {
        CheckPermissions.shared.checkCameraAccess { isAuthorised in
            if isAuthorised {
                if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                    
                    DispatchQueue.main.async {
                        self.picker.sourceType = .camera
                        self.picker.mediaTypes = ["public.movie"]
                        
                        // For trimming video
                        //self.picker.videoMaximumDuration = 300 // duration in seconds [5*60 = 300]
                        self.picker.allowsEditing = true
                        self.viewController.present(self.picker, animated: true, completion: nil)
                    }
                                
                } else {
                    //showAlert(msg: "You don't have camera", buttonTitle: [Messages.general.ok])
                    print("You don't have camera")
                    
                }
            }
            else {
                if self.allowSettingsNavigation {
                    AppSettings().askUserToOpenSettings(msg: MediaAccessMessages.needAccessOf.camera, viewController: self.viewController)
                }
            }
        }
        
        
    }
    
    func openVideoGallery(){
        CheckPermissions.shared.checkPhotoLibraryPermission { isAuthorised in
            if isAuthorised {
                DispatchQueue.main.async {
                    self.picker.sourceType = .photoLibrary
                    self.picker.mediaTypes = ["public.movie"]
                    
                    // For trimming video
                    //self.picker.videoMaximumDuration = 300 // duration in seconds [5*60 = 300]
                    self.picker.allowsEditing = true
                    self.viewController.present(self.picker, animated: true, completion: nil)
                }
            }
            else {
                if self.allowSettingsNavigation {
                    AppSettings().askUserToOpenSettings(msg: MediaAccessMessages.needAccessOf.photos, viewController: self.viewController)
                }
            }
        }
    }
}

extension MediaPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if selectionMediaType == .video {
            if let videoURL = info[.mediaURL] as? NSURL {
                pickedMediaCallback?(generateThumbnail(path: videoURL as URL)!, videoURL as URL)
            }
//            else if let asset = info[.phAsset] as? PHAsset {
//                let assetResources = PHAssetResource.assetResources(for: asset)
//                print(assetResources.first!.originalFilename)
//            }
            else if let videoURL = info[.referenceURL] as? URL {
                let assets = PHAsset.fetchAssets(withALAssetURLs: [videoURL], options: nil)
                if let firstAsset = assets.firstObject,
                let firstResource = PHAssetResource.assetResources(for: firstAsset).first {
                    print(firstResource)
                }
                pickedMediaCallback?(generateThumbnail(path: videoURL as URL)!, videoURL)
            }
        }
        else {
            guard let image = info[.originalImage] as? UIImage else {
                print("Expected a dictionary containing an image, but was provided the following: \(info)")
                return
            }
            
//            if self.allowCroping {
//                presentCropViewController(selectedImage: image)
//            }
//            else {
                pickedMediaCallback?(image, nil)
//            }
        }
    }



}

//
//extension MediaPickerManager: CropViewControllerDelegate
//{
//    func presentCropViewController(selectedImage: UIImage) {
//        let cropViewController = CropViewController(image: selectedImage)
//        cropViewController.rotateButtonsHidden = true
//        cropViewController.rotateClockwiseButtonHidden = true
//        cropViewController.resetButtonHidden = true
//        cropViewController.aspectRatioPickerButtonHidden = true
//        cropViewController.aspectRatioPreset = .presetSquare
//        cropViewController.delegate = self
//        DispatchQueue.main.async {
//            self.viewController.present(cropViewController, animated: true, completion: nil)
//        }
//    }
//
//    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//        DispatchQueue.main.async {
//            cropViewController.dismiss(animated: false, completion: nil)
//            self.pickedMediaCallback?(image, nil)
//        }
//    }
//
//    public func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
//        //print("Cancelled Image Selection While cropping")
//        DispatchQueue.main.async {
//            cropViewController.dismiss(animated: false, completion: nil)
//        }
//    }
//}
