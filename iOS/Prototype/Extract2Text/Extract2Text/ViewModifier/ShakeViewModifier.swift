//
//  ShakeViewModifier.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 08/07/2026.
//

import SwiftUI
import UIKit

extension NSNotification.Name {
    static let isShakeDetected = NSNotification.Name("com.extract2text.isShakeDetected")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .isShakeDetected, object: nil)
        }
    }
}

struct ShakeViewModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .isShakeDetected)) { _ in
                action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeViewModifier(action: action))
    }
}
