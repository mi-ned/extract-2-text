//
//  LiveScannerViewModel.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 26/03/2026.
//

import SwiftUI
import Combine
import AVFoundation

@MainActor
class LiveScannerViewModel: ObservableObject {
    
    @Published var outputBoxMessage: String = NSLocalizedString( "card_ui.output_box.scan_code", comment: "");
    @Published var timeRemaining: Double = 0.0
    @Published var zoomFactor: CGFloat = 1.0
    @Published var isFlashlightOn: Bool = false
    
    private var expirationDate: Date? = nil
    private let validator = ValidationService()
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    
    init(){
        setupSceneObservers()
    }
    
    deinit {
        timerCancellable?.cancel()
        timerCancellable = nil
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    private func setupSceneObservers() {
        NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.executeExpiration() }
            .store(in: &cancellables)
    }
    
    func processScan(scannedText: String) {
        
        guard expirationDate == nil else { return }
        
        guard let result = validator.validateData(scannedText: scannedText) else {
            //hapticFeedback(.error)
            return
        }
        
        outputBoxMessage = result.displayMessage
        
        if result.isSuccess {
            let code = scannedText.trimmingCharacters(in: .whitespacesAndNewlines)
            finishSuccessfulScan(code: code)
        } else {
            hapticFeedback(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                if self?.expirationDate == nil {
                    self?.outputBoxMessage = NSLocalizedString("card_ui.output_box.scan_code", comment: "")
                }
            }
        }
    }
    
    private func finishSuccessfulScan(code: String) {
        UIPasteboard.general.string = code
        hapticFeedback(.success)
        startTimer()
    }
    
    private func startTimer() {
        let duration = AppConfig.timerDurationInSeconds
        expirationDate = Date().addingTimeInterval(duration)
        
        timerCancellable = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self = self, let expiration = self.expirationDate else { return }
                let remaining = expiration.timeIntervalSince(now)
                if remaining <= 0 {
                    self.executeExpiration()
                } else {
                    self.timeRemaining = remaining
                }
            }
    }
    
    private func executeExpiration() {
        timerCancellable?.cancel()
        timerCancellable = nil
        expirationDate = nil
        timeRemaining = 0
        
        outputBoxMessage = NSLocalizedString("card_ui.output_box.clipboard_cleared", comment: "")
        UIPasteboard.general.string = ""
        hapticFeedback(.warning)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            
            if self.expirationDate == nil {
                self.outputBoxMessage = NSLocalizedString("card_ui.output_box.scan_code", comment: "")
            }
        }
    }
    
    var statusMessage: LocalizedStringKey {
        guard timeRemaining > 0 else { return "" }
        return LocalizedStringKey("card_ui.status_message.clearing_clipboard \(Int(ceil(timeRemaining)))")
    }
    
    private func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    func toggleFlashlight() {
        
        let shouldTurnOn = !isFlashlightOn
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            
            //guard let device = device, device.hasTorch else { return }
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                          device.hasTorch else { return }
            
            do {
                try device.lockForConfiguration()
                
                if shouldTurnOn {
                    if device.isTorchModeSupported(.on) {
                        try device.setTorchModeOn(level: 1.0)
                    }
                } else {
                    device.torchMode = .off
                }
                 
                device.unlockForConfiguration()
                            
                DispatchQueue.main.async {
                    self.isFlashlightOn = shouldTurnOn
                }
            } catch {
                print("Flashlight could not be used!")
            }
        }
    }
    
    func setZoom(_ factor: CGFloat) {
        
        let clamped = min(max(factor, 0.5), 40.0)
        self.zoomFactor = clamped
        
        /*guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
        
            let maxZoom = device.activeFormat.videoMaxZoomFactor
            let minZoom = device.activeFormat.Min
            
            let supportedMin = device.activeFormat
            
            let clampedLevel = min(max(factor, 0.5), 40.0)
            
            device.videoZoomFactor = clampedLevel
            self.zoomLevel = clampedLevel
            
            device.unlockForConfiguration()
        } catch {
            print("Camera zoom failed!")
        }*/
    }
    
    func cycleZoom() {
        let steps: [CGFloat] = [0.5, 1.0, 4.0, 8.0]
        let next = steps.first(where: { $0 > zoomFactor + 0.1}) ?? steps[0]
        setZoom(next)
    }
    
    func setExposure(_ value: Float) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            device.setExposureTargetBias(value)
            device.unlockForConfiguration()
        } catch {
            print("Camera exposure failed!")
        }
    }
}
