//
//  CameraManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 15/04/2026.
//

import AVFoundation

final class CameraManager {
    static let shared = CameraManager()
    private init() {}
    
    func setZoom(_ factor: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        try? device.lockForConfiguration()
        device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
        device.unlockForConfiguration()
    }
}
