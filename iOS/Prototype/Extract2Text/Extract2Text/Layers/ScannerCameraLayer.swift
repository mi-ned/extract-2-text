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

        DataScannerView(
            zoomFactor: $viewModel.zoomFactor,
            isScanning: $viewModel.isFlashlightBusying,
            onTextFound: { text in viewModel.processScan(scannedText: text) }
        )
        .ignoresSafeArea()
        }
    }
