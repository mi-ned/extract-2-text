//
//  CameraManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 03/06/2026.
//

import AVFoundation
import SwiftUI

enum CameraState {
    case idle, active, unauthorized, error, restricted
}

@Observable
class CameraManager {
    
    private let simulateError: Bool = false
    
    var state: CameraState = .idle
    let session: AVCaptureSession = AVCaptureSession()
    private let sessionQueue: DispatchQueue = DispatchQueue(label: "camera.session.queue")
    
    //Refactor further down...
    
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
                Task {
                    let granted = await AVCaptureDevice.requestAccess(for: .video)
                    if granted {
                        setupSession()
                    } else {
                        state = .unauthorized
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
                print("Manual test trigger: State set to .error")
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
            self.updateStatusOnMainActor(.active)
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
        
        NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionRuntimeError,
            object: session,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            
            if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
                if error.code == .mediaServicesWereReset {
                    self.start()
                } else {
                    self.state = .error
                }
            }
        }
    }
    
    private func updateStatusOnMainActor(_ newStatus: CameraState) {
        DispatchQueue.main.async { [weak self] in
            self?.state = newStatus
        }
    }
    
    func start() {
        let canStart = state == .active || state == .idle
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
            self?.state = .restricted
        }
    }
    
    func triggerTestError() {
        Task { @MainActor in
            self.state = .error
        }
        print("Test: CamerState set to .error")
    }
}
