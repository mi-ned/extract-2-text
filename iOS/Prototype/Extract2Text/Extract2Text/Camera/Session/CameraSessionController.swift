//
//  CameraSessionController.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 11/08/2026.
//

@preconcurrency import AVFoundation

final class CameraSessionController {
    func start(session: AVCaptureSession) {
        Task.detached(priority: .userInitiated) {
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    func stop(session: AVCaptureSession) {
        Task.detached(priority: .userInitiated) {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
}
