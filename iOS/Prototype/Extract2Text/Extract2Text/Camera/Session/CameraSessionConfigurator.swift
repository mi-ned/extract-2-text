//
//  CameraSessionConfigurator.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 11/08/2026.
//

@preconcurrency import AVFoundation
import Foundation

@MainActor
final class CameraSessionConfigurator {
    private let videoDataQueue = DispatchQueue(
        label: "com.extract2text.camera.videoDataQueue",
        qos: .userInitiated
    )
    private var cameraBufferProxy: CameraBufferProxy?
    
    func configure(
        session: AVCaptureSession,
        frameHandler: @escaping @Sendable (CMSampleBuffer) -> Void
    ) async -> Bool {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return false
        }
        
        let delegate = CameraBufferProxy(action: frameHandler)
        cameraBufferProxy = delegate
        
        return await Task.detached(priority: .userInitiated) { [videoDataQueue] in
            CameraSessionConfigurator.performBackgroundCameraSetup(
                session: session,
                camera: camera,
                delegate: delegate,
                queue: videoDataQueue
            )
        }.value
    }
    
    nonisolated private static func performBackgroundCameraSetup(
        session: AVCaptureSession,
        camera: AVCaptureDevice,
        delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) -> Bool {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        do {
            try configureCameraInput(for: session, device: camera)
            try configureVideoDataOutput(for: session, delegate: delegate, queue: queue)
            try configureCameraSettings(for: camera)
            
            session.commitConfiguration()
            return true
        } catch {
            session.commitConfiguration()
            print("Camera Setup Error: \(error)")
            return false
        }
    }
    
    nonisolated private static func configureCameraInput(
        for session: AVCaptureSession,
        device: AVCaptureDevice
    ) throws {
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            throw NSError(
                domain: "CameraSessionConfigurator",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Cannot add camera input to session"]
            )
        }
        session.addInput(input)
    }
    
    nonisolated private static func configureVideoDataOutput(
        for session: AVCaptureSession,
        delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) throws {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(delegate, queue: queue)
        
        guard session.canAddOutput(output) else {
            throw NSError(
                domain: "CameraSessionConfigurator",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Cannot add video output to session"]
            )
        }
        session.addOutput(output)
    }
    
    nonisolated private static func configureCameraSettings(for camera: AVCaptureDevice) throws {
        try camera.lockForConfiguration()
        defer { camera.unlockForConfiguration() }
        
        if camera.isFocusModeSupported(.continuousAutoFocus) {
            camera.focusMode = .continuousAutoFocus
        }
        
        let duration = CMTime(value: 1, timescale: 30)
        camera.activeVideoMinFrameDuration = duration
        camera.activeVideoMaxFrameDuration = duration
    }
}
