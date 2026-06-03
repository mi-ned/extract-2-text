//
//  Untitled.swift
//  Text2Text_prototype
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import SwiftUI
import VisionKit
import Combine

struct LiveScannerView: View {
    
    @StateObject private var viewModel = LiveScannerViewModel() //N
    
    var body: some View {
        
        ZStack {
            
            //Camera layer
            IsolatedCameraView(zoomFactor: $viewModel.zoomFactor, isScanning: $viewModel.isScanning, onScan: { text in viewModel.processScan(scannedText: text)})
            
            //Flashlight button
            VStack {
                
                FlashlightToggleButton(viewModel: viewModel)
                    .padding(.top, 64)
                
                Spacer()
                
                // Card UI
                ScannerOverlayCard(
                    message: viewModel.outputBoxMessage,
                    timeRemaining: viewModel.timeRemaining,
                    totalDuration: AppConfig.timerDurationInSeconds,
                    statusMessage: viewModel.statusMessage,
                    appInfo: String(localized: LocalizedStringResource("card_ui.footer.version_label \(AppConfig.appName) \(AppConfig.appVersion)"))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
    }
}
