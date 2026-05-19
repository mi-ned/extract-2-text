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
        HardwareQueues.serialAccessQueue.async { [weak self] in
            usleep(50000)
            guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
            
            do {

                try device.lockForConfiguration()
                
                defer { device.unlockForConfiguration() }
                
                let targetState: AVCaptureDevice.TorchMode = (device.torchMode == .on) ? .off : .on
                
                if targetState == .on {
                    try device.setTorchModeOn(level: 0.5)
                } else {
                    device.torchMode = .off
                }
                                
                DispatchQueue.main.async {
                    self?.isOn = (targetState == .on)
                }
            } catch {
                    print("Flashlight hardware busy: \(error)")
                }
            }
        }
    }
