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
    let isFlashlightOn: Bool
    var onTextFound: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true,
        )
        scanner.delegate = context.coordinator
        NotificationCenter.default.addObserver(forName: NSNotification.Name("StopScanner"), object: nil, queue: .main) { _ in
                scanner.stopScanning()
            }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("StartScanner"), object: nil, queue: .main) { _ in
                try? scanner.startScanning()
            }
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
        if uiViewController.zoomFactor != zoomFactor {
            uiViewController.zoomFactor = zoomFactor
        }
        
        if isFlashlightOn {
            uiViewController.view.setNeedsLayout()
            uiViewController.view.layoutIfNeeded()
        }
        
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
        
        /*if abs(uiViewController.zoomFactor - zoomFactor) > 0.01 {
            uiViewController.zoomFactor = zoomFactor
        }
        
        if !uiViewController.isScanning {
            Task {
                try? await Task.sleep(nanoseconds: 100_000_000)
                try? uiViewController.startScanning()
            }
        }*/
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
                if abs(parent.zoomFactor - dataScanner.zoomFactor) > 0.01 {
                    parent.zoomFactor = dataScanner.zoomFactor
                }
            }
        }
    }
}
