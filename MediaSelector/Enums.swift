//
//  Enums.swift
//  MediaSelector
//
//  Created by mac on 2022-08-19.
//

import Foundation


public enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}

public enum FlashStatus {
    case on
    case off
}

public enum MediaType {
    case image
    case video
    case audio
}

public enum Source {
    case camera
    case gallery
}




