//
//  CameraManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 15/04/2026.
//

import AVFoundation

class CameraManager {
    static let shared = CameraManager()
    
    var torchLevel: Float {
        guard let device = AVCaptureDevice.default(for: .video) else { return 0 }
        return device.torchMode == .on ? 1.0 : 0.0
    }

    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
    }
}
