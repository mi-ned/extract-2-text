//
//  Constants.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 23/03/2026.
//

import Foundation

struct AppConfig {
    static let timerDurationInSeconds: Double = 6.0
    
    static let appName: String =
        (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? "txeT2tcartxE"
    
    static let appVersion: String =
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0"
    
}

