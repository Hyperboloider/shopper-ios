//
//  ScannerFieldModel.swift
//  Shopper
//
//  Created by Гіяна Князєва on 22.12.2022.
//

import VisionKit
import Combine

final class ScannerFieldModel: ObservableObject {
    
    @Published var recentlyScannedCode: String = ""
    @Published private(set) var text = ""
    @Published var isScannerShown = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        subscribeOnScanner()
    }
        
    private func subscribeOnScanner() {
        $recentlyScannedCode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] upc in
                self?.text = upc
                self?.isScannerShown = false
            }
            .store(in: &subscriptions)
    }
    
}
