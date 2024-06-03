//
//  HapticsFeedbackGenerator.swift
//  Shopper
//
//  Created by Illia Kniaziev on 18.12.2022.
//

import UIKit

final class HapticsFeedbackGenerator {
    
    private init() {}
    
    static private let generator = UINotificationFeedbackGenerator()
    
    static func genereteFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
}
