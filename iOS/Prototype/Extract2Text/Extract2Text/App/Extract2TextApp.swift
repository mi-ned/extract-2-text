//
//  Text2Text_prototypeApp.swift
//  Text2Text_prototype
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import AppIntents
import SwiftUI

@main
struct Extract2TextApp: App {
    init() {
        ScannerShortcutsProvider.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            LiveScannerView()
        }
    }
}
