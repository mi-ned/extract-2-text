//
//  Untitled.swift
//  Text2Text_prototype
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import SwiftUI
import VisionKit
import Combine

struct ContentView: View {
    
    @State private var cameraManager = CameraManager()
    
    //@StateObject private var viewModel = LiveScannerViewModel()
    //private let showOverlay = false
    
    var body: some View {
        
        ZStack {
            
            //Camera layer
            if cameraManager.status == .error {
                CameraErrorAlertView(cameraManager: cameraManager)
                    .transition(.opacity)
            } else if cameraManager.status == .userDismissedError {
                CameraErrorView()
                    .transition(.opacity)
            } else {
                CameraPreviewView(session: cameraManager.session)
                    .onAppear { cameraManager.start() }
                    .onDisappear() { cameraManager.stop() }
                    .edgesIgnoringSafeArea(.all)
            }
                        
            /*if showOverlay {
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
            }*/
        }
        .animation(.easeInOut, value: cameraManager.status)
    }
}
