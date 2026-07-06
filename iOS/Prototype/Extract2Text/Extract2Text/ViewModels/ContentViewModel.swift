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
        cameraManager.state
    }
    
    public var session: AVCaptureSession {
        cameraManager.session
    }
    
    public init() {
        self.cameraManager = CameraManager()
    }
    
    public init(cameraManager: CameraManager){
        self.cameraManager = cameraManager
    }
    
    public func prepareCamera() async {
        await cameraManager.configureCamera()
    }
    
    public func startCamera() {
        cameraManager.start()
    }
    
    public func stopCamera() {
        cameraManager.stop()
    }
    
    public func dismissError() {
        cameraManager.dismissCurrentError()
    }
    
    
}
