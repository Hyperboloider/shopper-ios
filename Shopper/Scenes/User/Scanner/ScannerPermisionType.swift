//
//  ScannerPermisionType.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import Foundation

enum ScannerPermisionType: String {
    case none = "Let the app access the camera"
    case cameraAccessNotAllowed = "Grant the camera usage permission in settings"
    case cameraNotAvailable = "The camera is not available"
    case hardwareIncometable = "The device has no scanner ability"
    case allGood = "Everything is ready to go"
}
