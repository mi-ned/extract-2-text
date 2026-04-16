//
//  OutputBoxStyle.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct OutputBoxStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .regular))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.utility)
            .foregroundColor(Color.foreground)
            .cornerRadius(10)
    }
}
