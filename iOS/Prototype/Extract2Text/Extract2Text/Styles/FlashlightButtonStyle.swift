//
//  FlashlightButtonStyle.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct FlashlightButtonStyle: ViewModifier {
    var isOn: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(isOn ? .yellow : .white)
            .frame(width: 50, height: 50)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
    }
}
