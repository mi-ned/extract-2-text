//
//  ScannerIntents.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 14/04/2026.
//

import AppIntents
import Foundation

extension Notification.Name {
    static let toggleFlashlightRequested = Notification.Name("toggleFlashlightRequested")
}

struct ToggleFlashlightIntent: AppIntent {
    static let title: LocalizedStringResource = "Toggle Flashlight"
    static let description = IntentDescription("Turns the flashlight on or off.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .toggleFlashlightRequested, object: nil)
        return .result()
    }
}

struct ScannerShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleFlashlightIntent(),
            phrases: [
                "Toggle flashlight in \(.applicationName)",
                "Turn the flashlight on in \(.applicationName)",
                "Turn the flashlight off in \(.applicationName)"
            ],
            shortTitle: "Toggle Flashlight",
            systemImageName: "flashlight.on.fill"
        )
    }
}
