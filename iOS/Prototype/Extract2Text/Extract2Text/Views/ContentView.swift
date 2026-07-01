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
    
    @Bindable var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            //Camera layer
            switch viewModel.cameraState {
                case .error, .unauthorized:
                    CameraErrorAlertView(onDismiss: {
                        viewModel.dismissError()
                    })
                    .transition(.opacity)
                    
                case .restricted:
                    CameraErrorView()
                        .transition(.opacity)
                
                case .active, .idle:
                    CameraPreviewView(session: viewModel.session)
                        .onAppear { viewModel.startCamera() }
                        .onDisappear { viewModel.stopCamera() }
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
                }*/
                }
                .task {
                    await viewModel.prepareCamera()
                }
        .animation(.easeInOut, value: viewModel.cameraState)
    }
}
