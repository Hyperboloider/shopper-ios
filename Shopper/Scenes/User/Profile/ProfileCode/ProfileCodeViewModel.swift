//
//  ProfileCodeViewModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 31.12.2022.
//

import UIKit

final class ProfileCodeViewModel: ObservableObject {
    
    let id: String
    @Published private(set) var uiImage: UIImage?
        
    init(string: String) {
        self.id = string
        
        DispatchQueue.global(qos: .userInitiated).async {
            let uiImage = self.generateBarcode(from: string)
            DispatchQueue.main.async {
                self.uiImage = uiImage
            }
        }
    }
    
    private func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
}
