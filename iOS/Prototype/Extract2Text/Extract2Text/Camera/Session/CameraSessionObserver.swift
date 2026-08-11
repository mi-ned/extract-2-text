//
//  CameraSessionConfigurator.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 11/08/2026.
//

@preconcurrency import AVFoundation
import SwiftUI

@MainActor
@Observable

class CameraSessionObserver {
    
    private let captureSession: AVCaptureSession
    private let restartCamera: () -> Void
    private let transitionToErrorState: () -> Void
    private var cameraObserverTask: Task<Void, Never>?
    
    public init(
        captureSession: AVCaptureSession,
        restartCamera: @escaping () -> Void,
        transitionToErrorState: @escaping () -> Void
    ) {
        self.captureSession = captureSession
        self.restartCamera = restartCamera
        self.transitionToErrorState = transitionToErrorState
    }
    
    public func startSystemNotificationObservers() {
        
        let centre = NotificationCenter.default
        let session = captureSession
        
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
            restartCamera()
        }
    }
    
    private func observeSessionRuntimeError(in centre: NotificationCenter, for session: AVCaptureSession) async {
            let sequence = centre.notifications(named: .AVCaptureSessionRuntimeError, object: session)
            for await notification in sequence {
            guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { continue }
            if error.code == .mediaServicesWereReset {
                print("Media services reset. Restarting camera stream...")
                restartCamera()
            } else {
                transitionToErrorState()
            }
        }
    }
    public func stopSystemNotificationObservers(){
        cameraObserverTask?.cancel()
        cameraObserverTask = nil
    }
}

