//
//  LiveScannerViewModel.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 26/03/2026.
//

import SwiftUI
import Combine

@MainActor
class LiveScannerViewModel: ObservableObject {
    @Published var outputBoxMessage: String = NSLocalizedString( "card_ui.output_box.scan_code", comment: "");
    @Published var timeRemaining: Double = 0.0
    @Published var expirationDate: Date? = nil
    
    private let validator = ValidationService()
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    
    init(){
        setupSceneObservers()
    }

    private func setupSceneObservers() {
        NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.forceExpiry() }
            .store(in: &cancellables)
    }
    
    func processScan(scannedText: String) {
        
        guard expirationDate == nil else { return }
        
        guard let result = validator.validateData(scannedText: scannedText) else { return }
        
        switch result {
        case .validEAN(let code), .validTPBN(let code):
            let prefix = caseName(result) == "validEAN" ? "✅ Valid EAN" : "📦 Valid TPBN"
            outputBoxMessage = "\(prefix): \(code)"
            finishSuccessfulScan(code: code)
            
        case .invalidEAN:
            outputBoxMessage = "⚠️ Not valid EAN!"
            hapticFeedback(.error)
            
        case .invalidData:
            outputBoxMessage = "❌ Invalid Data!"
            hapticFeedback(.error)
            
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
        timeRemaining = duration
        
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self = self, let expiration = self.expirationDate else { return }
                let remaining = expiration.timeIntervalSince(now)
                if remaining <= 0 {
                    self.executeExpiration()
                } else {
                    self.timeRemaining = timeRemaining
                }
            }
    }
    
    private func executeExpiration() {
        timerCancellable = nil
        expirationDate = nil
        timeRemaining = 0
        outputBoxMessage = NSLocalizedString("card_ui.output_box.clipboard_cleared", comment: "")
        UIPasteboard.general.string = ""
        hapticFeedback(.warning)
    }
    
    func forceExpiry() {
        executeExpiration()
    }
    
    var statusMessage: LocalizedStringKey {
        guard timeRemaining > 0 else { return "" }
        return LocalizedStringKey("card_ui.status_message.clearing_clipboard \(Int(ceil(timeRemaining)))")
    }
    
    private func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    private func caseName(_ result: ValidationService.ScanResult) -> String {
        return Mirror(reflecting: result).children.first?.label ?? ""
    }
}
