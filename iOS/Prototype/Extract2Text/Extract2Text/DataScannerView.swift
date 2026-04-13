//
//  DataScannerViewController.swift
//  Text2Text_prototype
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    //@Binding var recognizedText: String
    
    var onTextFound: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTextFound: onTextFound)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onTextFound: (String) -> Void
        
        init(onTextFound: @escaping (String) -> Void) {
            self.onTextFound = onTextFound
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                onTextFound(text.transcript)
            default:
                break
            }
        }
    }
}
