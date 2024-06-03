//
//  PermissonManager.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import AVKit
import VisionKit

final class PermissonManager: ObservableObject {
    
    @Published var scannerPermissionStatus: ScannerPermisionType = .none
    
    @MainActor
    func requestPermission() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            scannerPermissionStatus = .cameraAccessNotAllowed
            return
        }
        
        let isScannerAvailable = DataScannerViewController.isAvailable && DataScannerViewController.isSupported
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            scannerPermissionStatus = isScannerAvailable ? .allGood : .hardwareIncometable
        case .restricted, .denied:
            scannerPermissionStatus = .cameraAccessNotAllowed
        case .notDetermined:
            let isAllowed = await AVCaptureDevice.requestAccess(for: .video)
            if isAllowed {
                scannerPermissionStatus = isScannerAvailable ? .allGood : .hardwareIncometable
            } else {
                scannerPermissionStatus = .cameraAccessNotAllowed
            }
        @unknown default:
            break
        }
    }
    
}
