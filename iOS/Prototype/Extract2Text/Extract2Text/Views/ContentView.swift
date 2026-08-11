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
            
            //Camera
            CameraPreviewView(session: viewModel.captureSession)
                .ignoresSafeArea()
                .onAppear { viewModel.startCamera() }
                .onDisappear { viewModel.stopCamera() }
            
            switch viewModel.cameraState {
                case .idle:
                    //TODO: Add idle UI here
                    EmptyView()
                case .active:
                    //TODO: Add overlay UI here
                    EmptyView()
                case .unauthorised, .error:
                    Color.black.ignoresSafeArea()
                    CameraErrorAlertView(onDismiss: {
                        viewModel.dismissCurrentError()
                    })
                    .transition(.opacity)
                case .restricted:
                    Color.black.ignoresSafeArea()
                    CameraErrorView()
                        .transition(.opacity)
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
             }
             */
        }
        .task {
            await viewModel.configureCamera()
        }
        .animation(.easeInOut, value: viewModel.cameraState)
    }
}
