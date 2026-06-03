//
//  CameraManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 03/06/2026.
//

import AVFoundation
import SwiftUI

enum CameraStatus {
    case idle, running, unauthorized, error, userDismissedError
}

@Observable
class CameraManager {
    
    private let simulateError = false
    
    var status: CameraStatus = .idle
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    init() {
        print("CameraManager Initialized!")
        setupSession()
        setupObservers()
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.simulateError {
                self.status = .error
                print("Manual test trigger: Status set to .error")
                return
            }
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            
            self.configureCaptureInput(for: camera)
        }
    }
    
    private func configureCaptureInput(for camera: AVCaptureDevice) {
        do {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            let input = try AVCaptureDeviceInput(device: camera)
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            self.session.commitConfiguration()
            self.status = .running
        } catch {
            self.status = .error
            print("Camera Setup Error: \(error)")
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .AVCaptureSessionWasInterrupted, object: session, queue: .main) { _ in
                print("Camera was interrupted by the system.")
        }
    }
    
    func start() {
        sessionQueue.async { [weak self] in
            if let session = self?.session, !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async { [weak self] in
            if let session = self?.session, session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    func triggerTestError() {
        self.status = .error
        print("Test: Status set to .error")
    }
}
