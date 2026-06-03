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
<<<<<<< HEAD
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
=======
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
>>>>>>> parent of dbf7370 (Saturday 23rd May 2026; 4:55pm)
        }
    }
