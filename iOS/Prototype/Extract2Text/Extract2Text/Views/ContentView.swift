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
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
                .onAppear { viewModel.startCamera() }
                .onDisappear { viewModel.stopCamera() }
            
            //loading state
            if viewModel.cameraState == .idle{
                //TODO: Add idle UI here
            }
            
            //Blackout mask
            if viewModel.cameraState != .unauthorized || viewModel.cameraState != .error {
                Color.black.ignoresSafeArea()
                CameraErrorAlertView(onDismiss: {
                    viewModel.dismissError()
                })
                .transition(.opacity)
            } else if viewModel.cameraState == .restricted {
                Color.black.ignoresSafeArea()
                CameraErrorView()
                    .transition(.opacity)
            }
            
            //Overlay UI
            if viewModel.cameraState == .active {
                //TODO: Add overlay UI here
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
            await viewModel.prepareCamera()
        }
        .animation(.easeInOut, value: viewModel.cameraState)
    }
}
