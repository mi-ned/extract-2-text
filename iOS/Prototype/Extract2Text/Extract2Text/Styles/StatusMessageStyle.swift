//
//  StatusMessageStyle.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct StatusMessageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color.foreground.opacity(0.8))
            .frame(maxWidth: .infinity)
    }
}
