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
    
    var isTorchOn: Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        return device.torchMode == .on
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        //if device.isTorchActive == (device.torchMode == .on) {
        // DispatchQueue.global(qos: .userInteractive).async {
        //if device.isTorchActive == (device.torchMode == .on) {
        do {
            try device.lockForConfiguration()
            //let nextMode: AVCaptureDevice.TorchMode = device.torchMode == .on ? .off : .on
            
            //device.torchMode = (device.torchMode == .on) ? .off : .on
            
            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
            
            if device.isExposureModeSupported(.continuousAutoExposure){
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print(error)
        }
    }
    
    func setZoom(_ factor: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        try? device.lockForConfiguration()
        device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
        device.unlockForConfiguration()
    }
}
