//
//  FooterStyle.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct VersionFooterStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(Color.foreground.opacity(0.6))
            .frame(maxWidth: .infinity)
    }
}
