//
//  ScannerIntents.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 14/04/2026.
//

import AppIntents
import AVFoundation

struct ToggleFlashlightIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Flashlight"
    
    @MainActor
    func perform() async throws -> some IntentResult {
        FlashlightManager.shared.toggleTorch()
        return .result()
    }
}
