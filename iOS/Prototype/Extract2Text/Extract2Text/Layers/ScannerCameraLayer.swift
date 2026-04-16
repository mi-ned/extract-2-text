//
//  ScannerCameraLayer.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct ScannerCameraLayer: View {
    @ObservedObject var viewModel: LiveScannerViewModel
    
    var body: some View {
        Group {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerView(zoomFactor: $viewModel.zoomFactor) { scannedText in
                    viewModel.processScan(scannedText: scannedText)
                }
            } else {
                Color.black
                    .overlay(
                        Text(String(localized: "main.camera.not_supported"))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        )
                    }
                }
        .ignoresSafeArea()
    }
}
