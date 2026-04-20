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
    
    private var resetTask: Task<Void, Never>? = nil
    
    init(){
        /*if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back){
            self.isFlashlightOn = (device.torchMode == .on)
        }*/
        setupSceneObservers()
    }
    
    deinit {
        timerCancellable?.cancel()
        //timerCancellable = nil
        
        cancellables.forEach { $0.cancel() }
        //cancellables.removeAll()
    }

    private func setupSceneObservers() {
        NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.executeExpiration() }
            .store(in: &cancellables)
    }
    
    func processScan(scannedText: String) {
        
        guard expirationDate == nil else { return }
        
        guard let result = validator.validateData(scannedText: scannedText) else { return }
        
        self.outputBoxMessage = String(localized: result.displayMessage)
        
        if result.isSuccess {
            finishSuccessfulScan(code: scannedText.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            HapticManager.shared.trigger(.error)
            triggerErrorReset()
        }
    }
    
    private func finishSuccessfulScan(code: String) {
        UIPasteboard.general.string = code
        HapticManager.shared.trigger(.success)
        startTimer()
    }
    
    private func triggerErrorReset() {
        
        resetTask?.cancel()
        
        resetTask = Task {
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            guard !Task.isCancelled else { return }
            
            if self.expirationDate == nil {
                self.outputBoxMessage = String(localized: "card_ui.output_box.scan_code")
            }
        }
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            
            guard let self = self else { return }
            
            if self.expirationDate == nil {
                self.outputBoxMessage = String(localized: "card_ui.output_box.scan_code")
            }
        }*/
    }
    
    private func startTimer() {
        timerCancellable?.cancel()
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
        HapticManager.shared.trigger(.warning)
        
        triggerErrorReset()
    }
    
    var statusMessage: LocalizedStringKey {
        guard timeRemaining > 0 else { return "" }
        return LocalizedStringKey("card_ui.status_message.clearing_clipboard \(Int(ceil(timeRemaining)))")
    }
    
    func toggleFlashlight() {
        CameraManager.shared.toggleTorch()
        self.isFlashlightOn = CameraManager.shared.isTorchOn
    }

    func cycleZoom() {
        let steps: [CGFloat] = [0.5, 1.0, 4.0, 8.0]
        let next = steps.first(where: { $0 > zoomFactor + 0.1}) ?? steps[0]
        self.zoomFactor = next
        CameraManager.shared.setZoom(next)
    }
}
