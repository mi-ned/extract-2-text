//
//  FlashlightManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 18/05/2026.
//

import AVFoundation

extension Notification.Name {
    static let torchStateChanged = Notification.Name("TorchStateChanged")
}

class FlashlightManager {
    static func toggleTorch() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
        device.hasTorch else { return }
        
            do {
                    try device.lockForConfiguration()
                    
                    let targetState: AVCaptureDevice.TorchMode = (device.torchMode == .on) ? .off : .on
                    
                    if targetState == .on {
                        try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                    } else {
                        device.torchMode = .off
                    }
                    
                    device.unlockForConfiguration()
                    
                    // Post the actual status to anyone listening (like the ViewModel)
                    let isOn = (targetState == .on)
                    NotificationCenter.default.post(name: .torchStateChanged, object: isOn)
                    
                } catch {
                    print("FlashlightManager: Error toggling torch: \(error.localizedDescription)")
                }
        }
    }

