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
    @Published var zoomFactor: CGFloat = 1.0
    @Published var timeRemaining: Double = 0.0
    
    private var expirationDate: Date? = nil
    
    private var timerCancellable: AnyCancellable?
    
    private var resetTask: Task<Void, Never>? = nil
    private var resumeScanningTask: Task<Void, Never>? = nil
    
    @Published var isFlashlightBusying: Bool = false
    @Published var isFlashlightOn: Bool = false
    @Published var isScanning: Bool = true
    
    private let validator = ValidationService()
    private var flashlightCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        FlashlightManager.shared.$isOn
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFlashlightOn)
        
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
        guard !isFlashlightBusying else { return }

        isFlashlightBusying = true
        FlashlightManager.shared.toggleTorch()

        resumeScanningTask?.cancel()
        resumeScanningTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }

            isFlashlightBusying = false
        }
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
