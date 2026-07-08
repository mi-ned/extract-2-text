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
class CameraManager: NSObject {
    
    private enum SessionSetupResult {
        case success
        case notAuthorised
        case setupError
    }
    
    public private(set) var cameraState: CameraState = .idle
    
    nonisolated let captureSession: AVCaptureSession = AVCaptureSession()
    private var sessionSetupResult: SessionSetupResult = .success
    private var cameraObserverTask: Task<Void, Never>?
    
    nonisolated private let videoDataQueue = DispatchQueue(
        label: "com.extract2text.camera.videoDataQueue",
        qos: .userInitiated
    )
    
    public override init() {
        print("CameraManager Initialized!")
        super.init()
        startSystemNotificationObservers()
    }
    
    public func configureCamera() async {
        guard cameraState == .idle else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                await setupRearCameraSession()
            case .notDetermined:
                let isGranted: Bool = await AVCaptureDevice.requestAccess(for: .video)
                if isGranted {
                    await setupRearCameraSession()
                } else {
                    self.sessionSetupResult = .notAuthorised
                    self.cameraState = .unauthorised
                }
            case .denied, .restricted:
                self.sessionSetupResult = .notAuthorised
                self.cameraState = .unauthorised
            @unknown default:
                self.cameraState = .error
        }
    }
    
    private func setupRearCameraSession() async {
        
        //Guard check
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            self.cameraState = .error
            return
        }
        
        //Closure allocation
        let delegate = CameraBufferProxy { [weak self] sampleBuffer in
            self?.handleFrameReceived(sampleBuffer)
        }
        
        //Offloading configuration to a background thread
        let isConfigured: Bool = await Task.detached(priority: .userInitiated) { [captureSession, videoDataQueue] in
            return CameraManager.performBackgroundCameraSetup(
                session: captureSession,
                camera: camera,
                delegate: delegate,
                queue: videoDataQueue
            )
        }.value
        
        //Updating MainActor state based on configuration result
        if isConfigured {
            self.sessionSetupResult = .success
            self.cameraState = .active
        } else {
            self.sessionSetupResult = .setupError
            self.cameraState = .error
        }
    }
    
    nonisolated private static func performBackgroundCameraSetup(session: AVCaptureSession, camera: AVCaptureDevice, delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue) -> Bool {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        do{
            try configureRearCameraInput(for: session, device: camera)
            
            try configureVideoDataOutput(for: session, delegate: delegate, queue: queue)
            
            try configureRearCameraSettings(for: camera)
            
            session.commitConfiguration()
            return true
        } catch {
            session.commitConfiguration()
            print("Camera Setup Error: \(error)")
            return false
        }
    }
    
    nonisolated private static func configureRearCameraInput(for session: AVCaptureSession, device: AVCaptureDevice) throws {
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            throw NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot add camera input to session"])
        }
        session.addInput(input)
    }
    
    nonisolated private static func configureVideoDataOutput(for session: AVCaptureSession, delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue) throws {
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(delegate, queue: queue)
        
        guard session.canAddOutput(output) else {
            throw NSError(domain: "CameraManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot add video output to session"])
        }
        session.addOutput(output)
    }
    
    nonisolated private static func configureRearCameraSettings(for camera: AVCaptureDevice) throws {
        try camera.lockForConfiguration()
        
        if camera.isFocusModeSupported(.continuousAutoFocus){
            camera.focusMode = .continuousAutoFocus
        }
        
        let duration = CMTime(value: 1, timescale: 30)
        camera.activeVideoMinFrameDuration = duration
        camera.activeVideoMaxFrameDuration = duration
        
        camera.unlockForConfiguration()
    }
    
    public func startCamera() {
        guard sessionSetupResult == .success else { return }
        let canStart = cameraState == .active || cameraState == .idle || cameraState == .restricted
        guard canStart else { return }
        
        let session = self.captureSession
        Task.detached(priority: .userInitiated) {
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    public func stopCamera() {
        let session = self.captureSession
        Task.detached(priority: .userInitiated) {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    public func dismissCurrentError(){
        self.cameraState = .restricted
    }
    
    public func triggerTestError() {
        self.cameraState = .error
        print("Test: CamerState set to .error")
    }
    
    private func startSystemNotificationObservers() {
        
        let centre = NotificationCenter.default
        let session = self.captureSession
        
        cameraObserverTask = Task { [weak self] in
            await withTaskGroup(of: Void.self) { group in
                
                group.addTask {
                    await self?.observeSessionWasInterrupted(in: centre, for: session)
                }
                
                group.addTask {
                    await self?.observeSessionInterruptionEnded(in: centre, for: session)
                }
                
                group.addTask{
                    await self?.observeSessionRuntimeError(in: centre, for: session)
                }
            }
        }
    }
    
    private func observeSessionWasInterrupted(in centre: NotificationCenter, for session: AVCaptureSession) async {
        
        let sequence = centre.notifications(named: .AVCaptureSessionWasInterrupted, object: session)
        for await _ in sequence {
            //guard self != nil else { return }
            //self?.state = .restricted
            print("Camera was interrupted by the system.")
        }
    }
    
    private func observeSessionInterruptionEnded(in centre: NotificationCenter, for session: AVCaptureSession) async {
        let sequence = centre.notifications(named: .AVCaptureSessionInterruptionEnded, object: session)
        for await _ in sequence {
            print("Interuption ended. Restoring video engine feed.")
            self.startCamera()
        }
    }
    
    private func observeSessionRuntimeError(in centre: NotificationCenter, for session: AVCaptureSession) async {
            let sequence = centre.notifications(named: .AVCaptureSessionRuntimeError, object: session)
            for await notification in sequence {
            guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { continue }
            if error.code == .mediaServicesWereReset {
                print("Media services reset. Restarting camera stream...")
                self.startCamera()
            } else {
                self.transitionToErrorState()
            }
        }
    }
    
    private func transitionToErrorState(){
        self.cameraState = .error
    }
    
    public func stopSystemNotificationObservers(){
        cameraObserverTask?.cancel()
        cameraObserverTask = nil
    }
    
    nonisolated private func handleFrameReceived(_ sampleBuffer: CMSampleBuffer) {
        // Handle the received frame here
    }
}
