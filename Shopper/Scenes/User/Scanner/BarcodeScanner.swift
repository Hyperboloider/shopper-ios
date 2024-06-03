//
//  BarcodeScanner.swift
//  Shopper
//
//  Created by Illia Kniaziev on 19.12.2022.
//

import SwiftUI
import VisionKit

struct BarcodeScanner: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: String
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: String

        init(recognizedItems: Binding<String>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            if let item = addedItems.first, case .barcode(let barcode) = item, let code = barcode.payloadStringValue {
                HapticsFeedbackGenerator.genereteFeedback(.success)
                recognizedItems = code
            }
        }
        
    }
    
}
