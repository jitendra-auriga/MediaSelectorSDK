//
//  Recorder.swift
//  MediaSelector
//
//  Created by mac on 2022-08-22.
//

import Foundation
import AVKit

public class Recorder: NSObject {
    
    static var shared = Recorder()
    private var audioRecorder:AVAudioRecorder!

    private override init() {}
    
    private func isRecordPermissionGranted(complition: @escaping (Bool) -> ()) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            complition(true)
            break
        case AVAudioSession.RecordPermission.denied:
            complition(false)
            break
        case AVAudioSession.RecordPermission.undetermined:
            DispatchQueue.main.async {
                AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        complition(true)
                    } else {
                        complition(false)
                    }
                })
            }
            break
        default:
            complition(false)
            break
        }
    }
    
    private func setupRecorder(complition: @escaping (Bool, String) -> ()) {
        isRecordPermissionGranted { isAudioRecordingGranted in
            if isAudioRecordingGranted {
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
                    try session.setActive(true)
                    let settings = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue
                    ]
                    self.audioRecorder = try AVAudioRecorder(url: self.getFileUrl(), settings: settings)
                    self.audioRecorder.delegate = self
                    self.audioRecorder.isMeteringEnabled = true
                    self.audioRecorder.prepareToRecord()
                    complition(true, "")
                }
                catch let error {
                    complition(false, error.localizedDescription)
                }
            }
            else {
                complition(false, "Please allow Microphone access.")
                //askUserToOpenSettings(msg: Messages.notFound.allowMicToRecord)
            }
        }
        
    }

    func getFileUrl() -> URL{
        print(FileHandler.shared.documentDirPath.absoluteString)
        return FileHandler.shared.documentDirPath.appendingPathComponent("Recording.m4a")
    }
    
    
    func startRecording(started: @escaping (Bool, String) -> ()){
        self.setupRecorder { status, errorMessage in
            if status {
                if self.audioRecorder != nil {
                    self.audioRecorder.record()
                    started(true, "")
                }
                else {
                    started(false, "Something went wrong woth recorder.")
                }
            }
            else {
                started(false, errorMessage)
            }
        }
    }
    
    func stopRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
}


extension Recorder: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording \(flag)")
    }
}
