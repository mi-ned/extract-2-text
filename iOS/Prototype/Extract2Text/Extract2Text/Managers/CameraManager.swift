//
//  CameraManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 03/06/2026.
//

@preconcurrency import AVFoundation
import SwiftUI

@Observable
@MainActor
class CameraManager {
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let simulateError: Bool = false
    public private(set) var state: CameraState = .idle
    let session: AVCaptureSession = AVCaptureSession()
    
    private var tokens: [Any] = []
    private var setupResult: SessionSetupResult = .success
    
    //Refactor further down...
    
    public init() {
        print("CameraManager Initialized!")
        setupObservers()
    }
    
    nonisolated deinit {
        
    }
    
    public func configureCamera() async {
        guard state == .idle else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                await setupSession()
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                if granted {
                    await setupSession()
                } else {
                    self.setupResult = .notAuthorized
                    self.state = .unauthorized
                }
            case .denied, .restricted:
                self.setupResult = .notAuthorized
                self.state = .unauthorized
            @unknown default:
                self.state = .error
        }
    }
    
    private func setupSession() async {
        if simulateError {
            self.state = .error
            return
        }
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            self.state = .error
            return
        }
        
        let captureSession = self.session
        
        let success = await Task.detached(priority: .userInitiated) {
            return CameraManager.performBackgroundSetup(session: captureSession, camera: camera)
        }.value
        
        if success {
            self.setupResult = .success
            self.state = .active
        } else {
            self.setupResult = .configurationFailed
            self.state = .error
        }
    }
    
    nonisolated private static func performBackgroundSetup(session: AVCaptureSession, camera: AVCaptureDevice) -> Bool {
        do{
            session.beginConfiguration()
            session.sessionPreset = .high
            
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                session.commitConfiguration()
                return false
            }
            
            try camera.lockForConfiguration()
            if camera.isFocusModeSupported(.continuousAutoFocus){
                camera.focusMode = .continuousAutoFocus
            }
            let duration = CMTime(value: 1, timescale: 30)
            camera.activeVideoMinFrameDuration = duration
            camera.activeVideoMaxFrameDuration = duration
            
            camera.unlockForConfiguration()
            session.commitConfiguration()
            return true
        } catch {
            session.commitConfiguration()
            print("Camera Setup Error: \(error)")
            return false
        }
    }
    
    public func start() {
        guard setupResult == .success else { return }
        let canStart = state == .active || state == .idle || state == .restricted
        guard canStart else { return }

        let captureSession = self.session
        Task.detached(priority: .userInitiated) {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
    
    public func stop() {
        let captureSession = self.session
        Task.detached(priority: .userInitiated) {
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }
    
    func dismissCurrentError(){
        self.state = .restricted
    }
    
    func triggerTestError() {
        self.state = .error
        print("Test: CamerState set to .error")
    }
    
    private func setupObservers() {
        
        let interruptedObserver = NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionWasInterrupted,
            object: session,
            queue: .main
        ) { _ in
            print("Camera was interrupted by the system.")
        }
        tokens.append(interruptedObserver)

        let endedObserver = NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionInterruptionEnded,
            object: session,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            print("Interuption ended. Restoring video engine feed.")
            Task { @MainActor in
                self.start()
            }
        }
        tokens.append(endedObserver)
        
        let errorObserver = NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionRuntimeError,
            object: session,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
                Task { @MainActor in
                    if error.code == .mediaServicesWereReset {
                        self.start()
                    } else {
                        self.state = .error
                    }
                }
            }
        }
        tokens.append(errorObserver)
    }
}
