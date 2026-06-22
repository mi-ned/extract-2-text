//
//  ContentViewModel.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 22/06/2026.
//

import SwiftUI
import Combine
import AVFoundation

@MainActor
@Observable
class ContentViewModel {
    private let cameraManager: CameraManager
    
    var cameraState: CameraState {
        cameraManager.state
    }
    
    var session: AVCaptureSession {
        cameraManager.session
    }
    
    init(cameraManager: CameraManager = CameraManager()) {
        self.cameraManager = cameraManager
    }
    
    func startCamera() {
        cameraManager.start()
    }
    
    func stopCamera() {
        cameraManager.stop()
    }
    
    func dismissError() {
        cameraManager.dismissCurrentError()
    }
    
    
}
