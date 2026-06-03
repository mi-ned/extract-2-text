//
//  FlashlightToggleButton.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct FlashlightToggleButton: View {
    @ObservedObject var viewModel: LiveScannerViewModel
    
    var body: some View {
        Button(action: { viewModel.toggleFlashlight() }) {
            Image(systemName: viewModel.isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                .modifier(FlashlightButtonStyle(isOn: viewModel.isFlashlightOn))
            }
    }
}
