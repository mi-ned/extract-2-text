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
        case notAuthorized
        case configurationFailed
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
        setupObservers()
    }
    
    public func configureCamera() async {
        guard cameraState == .idle else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                await setupCameraSession()
            case .notDetermined:
                let isAccessGranted: Bool = await AVCaptureDevice.requestAccess(for: .video)
                if isAccessGranted {
                    await setupCameraSession()
                } else {
                    self.sessionSetupResult = .notAuthorized
                    self.cameraState = .unauthorized
                }
            case .denied, .restricted:
                self.sessionSetupResult = .notAuthorized
                self.cameraState = .unauthorized
            @unknown default:
                self.cameraState = .error
        }
    }
    
    private func setupCameraSession() async {
        
        guard let rearCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            self.cameraState = .error
            return
        }
        
        let captureSession = self.captureSession
        let videoBufferQueue = self.videoDataQueue
        
        let frameOutputDelegate = CameraBufferProxy { [weak self] sampleBuffer in
            self?.handleFrameReceived(sampleBuffer)
        }
        
        let isConfigurationSuccessful = await Task.detached(priority: .userInitiated) {
            return CameraManager.performBackgroundCameraSetup(
                cameraSession: captureSession,
                rearCamera: rearCamera,
                outputBufferDelegate: frameOutputDelegate,
                outputDispatchQueue: videoBufferQueue
            )
        }.value
        
        if isConfigurationSuccessful {
            self.sessionSetupResult = .success
            self.cameraState = .active
        } else {
            self.sessionSetupResult = .configurationFailed
            self.cameraState = .error
        }
    }
    
    nonisolated private static func performBackgroundCameraSetup(
        cameraSession: AVCaptureSession,
        rearCamera: AVCaptureDevice,
        outputBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        outputDispatchQueue: DispatchQueue
    ) -> Bool {
        do{
            cameraSession.beginConfiguration()
            cameraSession.sessionPreset = .high
            
            let rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            if cameraSession.canAddInput(rearCameraInput) {
                cameraSession.addInput(rearCameraInput)
            } else {
                cameraSession.commitConfiguration()
                return false
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(outputBufferDelegate, queue: outputDispatchQueue)
            if cameraSession.canAddOutput(videoOutput){
                cameraSession.addOutput(videoOutput)
            } else {
                cameraSession.commitConfiguration()
                return false
            }
            
            try rearCamera.lockForConfiguration()
            if rearCamera.isFocusModeSupported(.continuousAutoFocus){
                rearCamera.focusMode = .continuousAutoFocus
            }
            let targetFrameRateDuration = CMTime(value: 1, timescale: 30)
            rearCamera.activeVideoMinFrameDuration = targetFrameRateDuration
            rearCamera.activeVideoMaxFrameDuration = targetFrameRateDuration
            
            rearCamera.unlockForConfiguration()
            cameraSession.commitConfiguration()
            return true
        } catch {
            cameraSession.commitConfiguration()
            print("Camera Setup Error: \(error)")
            return false
        }
    }
    
    public func start() {
        guard sessionSetupResult == .success else { return }
        let canStart = cameraState == .active || cameraState == .idle || cameraState == .restricted
        guard canStart else { return }
        
        let captureSession = self.captureSession
        Task.detached(priority: .userInitiated) {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
    
    public func stop() {
        let captureSession = self.captureSession
        Task.detached(priority: .userInitiated) {
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }
    
    func dismissCurrentError(){
        self.cameraState = .restricted
    }
    
    func triggerTestError() {
        self.cameraState = .error
        print("Test: CamerState set to .error")
    }
    
    private func setupObservers() {
        
        let center = NotificationCenter.default
        let sessionRef = self.captureSession
        
        cameraObserverTask = Task { [weak self] in
            await withTaskGroup(of: Void.self) { group in
                
                group.addTask {
                    let sequence = center.notifications(named: .AVCaptureSessionWasInterrupted, object: sessionRef)
                    for await _ in sequence {
                        guard self != nil else { return }
                        //self?.state = .restricted
                        print("Camera was interrupted by the system.")
                    }
                }
                
                group.addTask {
                    let sequence = center.notifications(named: .AVCaptureSessionInterruptionEnded, object: sessionRef)
                    for await _ in sequence {
                        print("Interuption ended. Restoring video engine feed.")
                        await self?.start()
                    }
                }
                
                group.addTask{
                    let sequence = center.notifications(named: .AVCaptureSessionRuntimeError, object: sessionRef)
                    for await notification in sequence {
                        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
                            if error.code == .mediaServicesWereReset {
                                await self?.start()
                            } else {
                                await self?.updateStateToError()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateStateToError(){
        self.cameraState = .error
    }
    
    public func cancelObservers(){
        cameraObserverTask?.cancel()
        cameraObserverTask = nil
    }
    
    nonisolated private func handleFrameReceived(_ sampleBuffer: CMSampleBuffer) {
        // Handle the received frame here
    }
}
