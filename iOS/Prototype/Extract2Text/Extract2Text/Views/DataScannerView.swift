//
//  DataScannerViewController.swift
//  Text2Text_prototype
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var zoomFactor: CGFloat
    var onTextFound: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
        if uiViewController.zoomFactor != zoomFactor {
            uiViewController.zoomFactor = zoomFactor
        }
        
        if !uiViewController.isScanning && !context.coordinator.isStarting {
            context.coordinator.isStarting = true
            
            try? uiViewController.startScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScannerView
        var isStarting = false
        
        init(_ parent: DataScannerView) { self.parent = parent }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .text(let text) = item {
                parent.onTextFound(text.transcript)
            }
        }
    }
}
