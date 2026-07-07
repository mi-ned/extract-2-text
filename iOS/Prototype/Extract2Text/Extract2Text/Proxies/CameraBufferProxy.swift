//
//  CameraBufferProxy.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 07/07/2026.
//

import AVFoundation

public final class CameraBufferProxy: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, Sendable {
    let onFrame: @Sendable (CMSampleBuffer) -> Void
    
    init(onFrame: @escaping @Sendable (CMSampleBuffer) -> Void) {
        self.onFrame = onFrame
        super.init()
    }
    
    public nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        onFrame(sampleBuffer)
    }
}
