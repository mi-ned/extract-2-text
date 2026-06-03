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
        HardwareQueues.serialAccessQueue.async {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            var lockAquired = false
            var attempts = 0
            while !lockAquired && attempts < 3 {
                if (try? device.lockForConfiguration()) != nil {
                    lockAquired = true
                } else {
                    attempts += 1
                    usleep(50000)
                }
            }
            
            guard lockAquired else { return }
                    
            let zoom = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = zoom
            device.unlockForConfiguration()
        }
    }
}
