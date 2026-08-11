//
//  CameraManager.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 03/06/2026.
//

@preconcurrency import AVFoundation
import Observation

@Observable
@MainActor
class CameraManager: NSObject {
    public private(set) var cameraState: CameraState = .idle
    nonisolated let captureSession = AVCaptureSession()
    
    private let sessionConfigurator = CameraSessionConfigurator()
    private let sessionController = CameraSessionController()
    private var cameraSessionObserver: CameraSessionObserver?
    
    public override init() {
        print("CameraManager Initialized!")
        super.init()
        startObservingSessionEvents()
    }
    
    public func configureCamera() async {
        guard cameraState == .idle else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                await setupCameraSession()
            case .notDetermined:
                await requestCameraAccessAndSetupSession()
            case .denied, .restricted:
                transitionToUnauthorisedState()
            @unknown default:
                transitionToErrorState()
        }
    }
    
    public func startCamera() {
        guard cameraState.canStartCamera else { return }
        sessionController.start(session: captureSession)
    }
    
    public func stopCamera() {
        sessionController.stop(session: captureSession)
    }
    
    public func dismissCurrentError() {
        cameraState = .restricted
    }
    
    public func triggerTestError() {
        cameraState = .error
        print("Test: CameraState set to .error")
    }
    
    private func requestCameraAccessAndSetupSession() async {
        let isGranted = await AVCaptureDevice.requestAccess(for: .video)
        if isGranted {
            await setupCameraSession()
        } else {
            transitionToUnauthorisedState()
        }
    }
    
    private func setupCameraSession() async {
        let isConfigured = await sessionConfigurator.configure(
            session: captureSession,
            frameHandler: { [weak self] sampleBuffer in
                self?.handleFrameReceived(sampleBuffer)
            }
        )
        
        cameraState = isConfigured ? .active : .error
    }
    
    private func startObservingSessionEvents() {
        cameraSessionObserver = CameraSessionObserver(
            captureSession: captureSession,
            restartCamera: { [weak self] in
                self?.startCamera()
            },
            transitionToErrorState: { [weak self] in
                self?.transitionToErrorState()
            }
        )
        cameraSessionObserver?.startSystemNotificationObservers()
    }
    
    private func transitionToUnauthorisedState() {
        cameraState = .unauthorised
    }
    
    private func transitionToErrorState() {
        cameraState = .error
    }
    
    nonisolated private func handleFrameReceived(_ sampleBuffer: CMSampleBuffer) {
        // Handle the received frame here
    }
}

private extension CameraState {
    var canStartCamera: Bool {
        self == .active || self == .idle || self == .restricted
    }
}
