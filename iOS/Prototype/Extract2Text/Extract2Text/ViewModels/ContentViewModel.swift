//
//  ContentViewModel.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 22/06/2026.
//

import SwiftUI
import AVFoundation

@MainActor
@Observable
class ContentViewModel {
    
    private let cameraManager: CameraManager
    
    public var cameraState: CameraState {
        cameraManager.cameraState
    }
    
    public var captureSession: AVCaptureSession {
        cameraManager.captureSession
    }
    
    public init() {
        self.cameraManager = CameraManager()
    }
    
    public init(cameraManager: CameraManager){
        self.cameraManager = cameraManager
    }
    
    public func configureCamera() async {
        await cameraManager.configureCamera()
    }
    
    public func startCamera() {
        cameraManager.startCamera()
    }
    
    public func stopCamera() {
        cameraManager.stopCamera()
    }
    
    public func dismissCurrentError() {
        cameraManager.dismissCurrentError()
    }
}

#if DEBUG
extension ContentViewModel {
    func simulateHardwareFailure(){
        cameraManager.triggerTestError()
    }
}
#endif
