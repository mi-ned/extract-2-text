//
//  IsolatedCameraView.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 19/05/2026.
//

import SwiftUI
import VisionKit
import Combine

struct IsolatedCameraView: View {
    @Binding var zoomFactor: CGFloat
    let onScan: (String) -> Void
    
    var body: some View {
        DataScannerView(
            zoomFactor: $zoomFactor,
            onTextFound: onScan
        )
            .ignoresSafeArea()
    }
}
