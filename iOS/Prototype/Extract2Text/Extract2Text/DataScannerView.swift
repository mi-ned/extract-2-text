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
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true,
        )
        scanner.delegate = context.coordinator
        //try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
        if uiViewController.zoomFactor != zoomFactor {
            uiViewController.zoomFactor = zoomFactor
        }
        
        
        //if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        //}
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        var parent: DataScannerView
        
        init(parent: DataScannerView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.onTextFound(text.transcript)
            default:
                break
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didBecomActiveWithError error: (any Error)?) {
            if error == nil {
                parent.zoomFactor = dataScanner.zoomFactor
            }
            
        }
        
        
        /*var onTextFound: (String) -> Void
        var hasStarted = false
        
        init(onTextFound: @escaping (String) -> Void) {
            self.onTextFound = onTextFound
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didBecomeActiveWithError error: (any Error)?) {
            guard !hasStarted else { return }
            try? dataScanner.startScanning()
            hasStarted = true
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                onTextFound(text.transcript)
            default:
                break
            }
        }*/
    }
}
