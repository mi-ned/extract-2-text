//
//  FlashlightManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 18/05/2026.
//

import AVFoundation
import SwiftUI
import Combine

final class FlashlightManager: ObservableObject {
    static let shared = FlashlightManager()
    @Published var isOn: Bool = false
    private init() {}
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              device.hasTorch,
              device.isTorchAvailable else { return }
                
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if device.torchMode == .on {
                device.torchMode = .off
                isOn = false
            } else if device.isTorchModeSupported(.on) {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                isOn = true
            }
        } catch {
            print("Could not lock hardware: \(error)")
        }
    }
}
