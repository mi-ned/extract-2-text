//
//  HapticManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 15/04/2026.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private let generator = UINotificationFeedbackGenerator()
    
    private init() {
        generator.prepare()
    }
    
    func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
        generator.prepare()
    }
}
