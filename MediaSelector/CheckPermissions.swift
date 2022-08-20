//
//  CheckPermissions.swift
//  MediaSelector
//
//  Created by mac on 2022-08-22.
//

import Foundation
import Photos


public class CheckPermissions {
    
    static let shared = CheckPermissions()
    private init() {}
    
    func checkPhotoLibraryPermission(isAuthorized: @escaping (Bool) -> () = {_ in}) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            isAuthorized(true)
            break
        //handle authorized status
        case .denied, .restricted :
            isAuthorized(false)
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    isAuthorized(true)
                    break
                case .denied, .restricted:
                    isAuthorized(false)
                    break
                case .notDetermined: break
                // won't happen but still
                case .limited:
                    isAuthorized(false)
                    break
                @unknown default:
                    break
                }
            }
        case .limited:
            break
        @unknown default:
            break
        }
    }
    
    func checkCameraAccess(isAuthorized: @escaping (Bool) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            isAuthorized(false)
            break
        case .restricted:
            print("Restricted, device owner must approve")
            isAuthorized(false)
            break
        case .authorized:
            print("Authorized, proceed")
            isAuthorized(true)
            break
        case .notDetermined:
            DispatchQueue.main.async {
                AVCaptureDevice.requestAccess(for: .video) { success in
                    isAuthorized(success)
                }
            }
            break
        @unknown default:
            isAuthorized(false)
        }
    }
    
    func checkMicPermission(isAuthorized: @escaping (Bool) -> ()) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAuthorized(true)
            break
        case AVAudioSession.RecordPermission.denied:
            isAuthorized(false)
            break
        case AVAudioSession.RecordPermission.undetermined:
            DispatchQueue.main.async {
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    if granted {
                        isAuthorized(true)
                    } else {
                        isAuthorized(false)
                    }
                })
            }
            break
        default:
            isAuthorized(false)
            break
        }
    }
    
}

