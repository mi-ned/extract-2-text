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
        checkPermissionsAndSetup()
        setupObservers()
    }
    
    private func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            // Request permission explicitly
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupSession()
                } else {
                    self?.updateStatusOnMainActor(.unauthorized)
                }
            }
        case .denied, .restricted:
            updateStatusOnMainActor(.unauthorized)
        @unknown default:
            updateStatusOnMainActor(.error)
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.simulateError {
                self.updateStatusOnMainActor(.error)
                print("Manual test trigger: Status set to .error")
                return
            }
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.updateStatusOnMainActor(.error)
                return
            }
            
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
            } else {
                self.session.commitConfiguration()
                self.updateStatusOnMainActor(.error)
                return
            }
            
            try camera.lockForConfiguration()
            
            if camera.isFocusModeSupported(.continuousAutoFocus){
                camera.focusMode = .continuousAutoFocus
            }
            
            let duration = CMTime(value: 1, timescale: 30)
            camera.activeVideoMinFrameDuration = duration
            camera.activeVideoMaxFrameDuration = duration
            
            camera.unlockForConfiguration()
            
            self.session.commitConfiguration()
            self.updateStatusOnMainActor(.running)
        } catch {
            self.session.commitConfiguration()
            self.updateStatusOnMainActor(.error)
            print("Camera Setup Error: \(error)")
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionWasInterrupted,
            object: session,
            queue: .main
        ) { [weak self] _ in
            print("Camera was interrupted by the system.")
        }
        
        NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionInterruptionEnded,
            object: session,
            queue: .main,
        ) { [weak self] _ in
            print("Interruption ended. Restoring video engine feed.")
            self?.start()
        }
    }
    
    private func updateStatusOnMainActor(_ newStatus: CameraStatus) {
        DispatchQueue.main.async { [weak self] in
            self?.status = newStatus
        }
    }
    
    func start() {
        let canStart = status == .running || status == .idle
        guard canStart else { return }

        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
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
    
    func dismissCurrentError(){
        DispatchQueue.main.async { [weak self] in
            self?.status = .userDismissedError
        }
    }
    
    func triggerTestError() {
        Task { @MainActor in
            self.status = .error
        }
        print("Test: Status set to .error")
    }
}
