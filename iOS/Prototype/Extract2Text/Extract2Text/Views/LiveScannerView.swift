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
        
        ZStack(alignment: .bottom) {
            
            //Camera layer
            ScannerCameraLayer(viewModel: viewModel)
    
            VStack {
                HStack {
                    //Flashlight button
                    FlashlightToggleButton(viewModel: viewModel)
                        .padding(.top, 128)
                        .modifier(FlashlightButtonStyle(isOn: viewModel.isFlashlightOn, background: AnyShapeStyle(Color.black)))
                    Spacer()
                }
                Spacer()
                
                // Card UI
                ScannerOverlayCard(
                    message: viewModel.outputBoxMessage,
                    timeRemaining: viewModel.timeRemaining,
                    totalDuration: AppConfig.timerDurationInSeconds,
                    statusMessage: viewModel.statusMessage,
                    appInfo: String(localized: "card_ui.footer.version_label\(AppConfig.appName) \(AppConfig.appVersion)")
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
    }
}
