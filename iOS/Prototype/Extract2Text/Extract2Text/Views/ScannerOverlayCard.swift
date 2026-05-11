//
//  ScannerOverlayCard.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct ScannerOverlayCard: View {
    let message: String
    let timeRemaining: Double
    let totalDuration: Double
    let statusMessage: LocalizedStringResource
    let appInfo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TimerBar(timerProgress: timeRemaining / totalDuration)
            
            Text(message)
                .modifier(OutputBoxStyle())
            
            Text(statusMessage)
                .modifier(StatusMessageStyle())
            
            Text(appInfo)
                .modifier(VersionFooterStyle())
        }
        .padding([.bottom, .top], 20)
        .padding(.horizontal, 16)
        .background(Color.tile)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}
