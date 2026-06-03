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
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
                
        do {
            try device.lockForConfiguration()
            let targetState: AVCaptureDevice.TorchMode = (device.torchMode == .on) ? .off : .on
            device.torchMode = targetState
            device.unlockForConfiguration()
            self.isOn = (targetState == .on)
        } catch {
            print("Could not lock hardware: \(error)")
        }
    }
}
