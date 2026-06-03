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
    
    @Published var outputBoxMessage: String = String(localized:  "card_ui.output_box.scan_code")
    @Published var zoomFactor: CGFloat = 1.0 {
        didSet {
            if abs(oldValue - zoomFactor) > 0.05 {
                CameraManager.shared.setZoom(zoomFactor)
            }
        }
    }
    @Published var timeRemaining: Double = 0.0
    
    private var expirationDate: Date? = nil
    
    private var timerCancellable: AnyCancellable?
    
    private var resetTask: Task<Void, Never>? = nil
    private var resumeScanningTask: Task<Void, Never>? = nil
    
    @Published var isFlashlightOn: Bool = false
    
    private let validator = ValidationService()
    private var flashlightCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        FlashlightManager.shared.$isOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                if self?.isFlashlightOn != newValue {
                    self?.isFlashlightOn = newValue
                }
            }
            .store(in: &cancellables)
        
        setupSceneObservers()
    }
    
    deinit {
        timerCancellable?.cancel()
        //timerCancellable = nil
        
        resumeScanningTask?.cancel()
        cancellables.forEach { $0.cancel() }
        //cancellables.removeAll()
    }

    private func setupSceneObservers() {
        NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.executeExpiration() }
            .store(in: &cancellables)
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
    }
    
    private func startClipboardTimer() {
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
        
        outputBoxMessage = String(localized: "card_ui.output_box.clipboard_cleared")
        UIPasteboard.general.string = ""
        HapticManager.shared.trigger(.warning)
        
        triggerErrorReset()
    }
    
    var statusMessage: LocalizedStringResource {
        guard timeRemaining > 0 else { return LocalizedStringResource("\u{200B}") }
        return LocalizedStringResource("card_ui.status_message.clearing_clipboard \(Int(ceil(timeRemaining)))")
    }
    
    func toggleFlashlight() {
<<<<<<< HEAD
        guard !isFlashlightBusying else { return }

        isFlashlightBusying = true
        FlashlightManager.shared.toggleTorch()

        resumeScanningTask?.cancel()
        resumeScanningTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }

            isFlashlightBusying = false
        }
=======
        FlashlightManager.shared.toggleTorch()
>>>>>>> parent of dbf7370 (Saturday 23rd May 2026; 4:55pm)
    }
        
    func processScan(scannedText: String) {
        guard let result = validator.validateData(scannedText: scannedText) else { return }
                
        if result.isSuccess {
            UIPasteboard.general.string = scannedText
            startClipboardTimer()
            HapticManager.shared.trigger(.success)
        }
        outputBoxMessage = String(localized: result.displayMessage)
    }

    func cycleZoom() {
        let steps: [CGFloat] = [0.5, 1.0, 4.0, 8.0]
        let next = steps.first(where: { $0 > zoomFactor + 0.1}) ?? steps[0]
        self.zoomFactor = next
        //CameraManager.shared.setZoom(next)
    }
}
