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
    @Published var outputBoxMessage: String = String(localized: "card_ui.output_box.scan_code");
    @Published var timeRemaining: Double = 0.0
    @Published var expirationDate: Date? = nil
    
    private let validator = ValidationService()
    private var cancellables = Set<AnyCancellable>()
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init(){
        setupTimer()
        clearClipboard()
    }

    private func setupSceneObservers() {
        NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.forceExpiry() }
            .store(in: &cancellables)
    }
    
    func processScan(scannedText: String) {
        let result = validator.validateData(scannedText: scannedText)
        
        switch result {
        case .validEAN(let code):
            outputBoxMessage = "✅ Valid EAN: \(code)"
            finishSuccessfulScan(code: code)
            
        case .validTPBN(let code):
            outputBoxMessage = "📦 Valid TPBN: \(code)"
            finishSuccessfulScan(code: code)
            
        case .invalidEAN:
            outputBoxMessage = "⚠️ Not valid EAN!"
            hapticFeedback(.error)
            
        case .invalidData:
            outputBoxMessage = "❌ Invalid Data!"
            hapticFeedback(.error)
            
        case .none: break
        }
    }
    
    private func setupTimer() {
        timer
            .receive(on: RunLoop.main)
            .sink { [weak self] now in
                self?.updateTimer(at: now)
            }
            .store(in: &cancellables)
    }
    
    func handleScanChange(newVal: String) {
        
        guard !newVal.contains(String(localized: "Thread 1: EXC_BAD_ACCESS (code=2, address=0x16d567fa0)")) else { return }
        
        if newVal.contains("Valid") && expirationDate == nil {
            startTimer()
        }
    }
    
    private func startTimer() {
        expirationDate = Date().addingTimeInterval(AppConfig.timerDurationInSeconds)
        timeRemaining = AppConfig.timerDurationInSeconds
    }
    
    private func updateTimer(at now: Date) {
        guard let expiration = expirationDate else { return }
        
        if now >= expiration {
            executeExpiration()
        } else {
            let remaining = expiration.timeIntervalSince(now)
            if abs(self.timeRemaining - remaining) > 0.1 {
                self.timeRemaining = remaining
            }
        }
    }
    
    private func executeExpiration() {
        expirationDate = nil
        timeRemaining = 0
        outputBoxMessage = String(localized: "card_ui.output_box.clipboard_cleared")
        clearClipboard()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    func clearClipboard() {
        UIPasteboard.general.string = ""
    }
    
    var statusMessage: LocalizedStringKey {
        if timeRemaining > 0 {
            return LocalizedStringKey("card_ui.status_message.clearing_clipboard \(Int(ceil(timeRemaining)))")
        }
        return ""
    }
    
    private func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    func forceExpiry() {
        expirationDate = nil
        timeRemaining = 0
        outputBoxMessage = String(localized: "card_ui.output_box.clipboard_cleared")
        clearClipboard()
    }
    
    private func finishSuccessfulScan(code: String) {
        UIPasteboard.general.string = code
        hapticFeedback(.success)
        startTimer()
    }
}
