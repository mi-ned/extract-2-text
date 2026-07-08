//
//  CameraBufferProxy.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 07/07/2026.
//

import AVFoundation

public final class CameraBufferProxy: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, Sendable {
    let action: @Sendable (CMSampleBuffer) -> Void
    
    init(action: @escaping @Sendable (CMSampleBuffer) -> Void) {
        self.action = action
        super.init()
    }
    
    public nonisolated func captureRearCameraOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        action(sampleBuffer)
    }
}
