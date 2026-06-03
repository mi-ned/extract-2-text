//
//  DataScannerView.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import AVFoundation
import SwiftUI
import UIKit
import Vision

struct DataScannerView: UIViewRepresentable {
    @Binding var zoomFactor: CGFloat
    var onTextFound: (String) -> Void
<<<<<<< HEAD

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.onTap = { point in
            context.coordinator.handleTap(at: point)
        }
        context.coordinator.configureSession(for: view)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.previewView = uiView
        context.coordinator.setTextRecognitionEnabled(isScanning)
        context.coordinator.setZoomFactor(zoomFactor) { clampedZoom in
            if abs(zoomFactor - clampedZoom) > 0.001 {
                zoomFactor = clampedZoom
            }
=======
    
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
>>>>>>> parent of dbf7370 (Saturday 23rd May 2026; 4:55pm)
        }
        
        if !uiViewController.isScanning && !context.coordinator.isStarting {
            context.coordinator.isStarting = true
            
            try? uiViewController.startScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: Coordinator) {
        coordinator.stopSession()
    }
}

final class PreviewView: UIView {
    var onTap: ((CGPoint) -> Void)?

    private let highlightLayer = CALayer()
    private let guidanceLabel = UILabel()

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        highlightLayer.frame = bounds
        guidanceLabel.frame = CGRect(x: 24, y: max(safeAreaInsets.top + 72, 96), width: bounds.width - 48, height: 34)
    }

    func updateHighlights(_ items: [RecognizedTextItem]) {
        highlightLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        for item in items {
            let boxLayer = CAShapeLayer()
            boxLayer.path = UIBezierPath(roundedRect: item.layerRect, cornerRadius: 8).cgPath
            boxLayer.fillColor = UIColor.systemYellow.withAlphaComponent(0.18).cgColor
            boxLayer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.95).cgColor
            boxLayer.lineWidth = 2
            highlightLayer.addSublayer(boxLayer)
        }

        guidanceLabel.text = items.isEmpty ? "Find text" : "Tap highlighted text"
    }

    func showSelection(_ rect: CGRect) {
        let selectionLayer = CAShapeLayer()
        selectionLayer.path = UIBezierPath(roundedRect: rect.insetBy(dx: -4, dy: -4), cornerRadius: 10).cgPath
        selectionLayer.fillColor = UIColor.clear.cgColor
        selectionLayer.strokeColor = UIColor.systemGreen.cgColor
        selectionLayer.lineWidth = 3
        highlightLayer.addSublayer(selectionLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak selectionLayer] in
            selectionLayer?.removeFromSuperlayer()
        }
    }

    private func setupOverlay() {
        isUserInteractionEnabled = true
        videoPreviewLayer.addSublayer(highlightLayer)

        guidanceLabel.text = "Find text"
        guidanceLabel.textAlignment = .center
        guidanceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        guidanceLabel.textColor = .white
        guidanceLabel.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        guidanceLabel.layer.cornerRadius = 17
        guidanceLabel.layer.masksToBounds = true
        guidanceLabel.adjustsFontSizeToFitWidth = true
        guidanceLabel.minimumScaleFactor = 0.8
        addSubview(guidanceLabel)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapRecognizer)
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        onTap?(recognizer.location(in: self))
    }
}

struct RecognizedTextItem: Equatable {
    let text: String
    let layerRect: CGRect
    let confidence: Float
}

extension DataScannerView {
    final class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: DataScannerView
<<<<<<< HEAD
        weak var previewView: PreviewView?

        private let session = AVCaptureSession()
        private let videoOutput = AVCaptureVideoDataOutput()
        private let sessionQueue = HardwareQueues.serialAccessQueue
        private let visionQueue = DispatchQueue(label: "com.extract2text.vision.text")
        private var captureDevice: AVCaptureDevice?
        private var isConfigured = false
        private var isTextRecognitionEnabled = true
        private var isProcessingFrame = false
        private var lastRecognitionDate = Date.distantPast
        private var recognizedItems: [RecognizedTextItem] = []

        init(parent: DataScannerView) {
            self.parent = parent
            super.init()
        }

        func configureSession(for view: PreviewView) {
            previewView = view
            view.videoPreviewLayer.session = session

            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                configureAndStartSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    guard granted else { return }
                    self?.configureAndStartSession()
                }
            default:
                break
            }
        }

        func stopSession() {
            sessionQueue.async { [session] in
                if session.isRunning {
                    session.stopRunning()
                }
            }
        }

        func setTextRecognitionEnabled(_ isEnabled: Bool) {
            sessionQueue.async { [weak self] in
                self?.isTextRecognitionEnabled = isEnabled
            }
        }

        func setZoomFactor(_ zoomFactor: CGFloat, onClamp: @escaping @MainActor (CGFloat) -> Void) {
            sessionQueue.async { [weak self] in
                guard let self, let captureDevice else { return }

                let requestedZoom = max(1.0, zoomFactor)
                let maxZoom = min(captureDevice.activeFormat.videoMaxZoomFactor, 8.0)
                let clampedZoom = min(max(requestedZoom, 1.0), maxZoom)

                do {
                    try captureDevice.lockForConfiguration()
                    captureDevice.videoZoomFactor = clampedZoom
                    captureDevice.unlockForConfiguration()
                } catch {
                    print("Unable to set camera zoom: \(error)")
                    return
                }

                if abs(zoomFactor - clampedZoom) > 0.001 {
                    Task { @MainActor in
                        onClamp(clampedZoom)
                    }
                }
            }
        }

        @MainActor
        func handleTap(at point: CGPoint) {
            guard let selectedItem = recognizedItems
                .filter({ $0.layerRect.insetBy(dx: -16, dy: -16).contains(point) })
                .min(by: { $0.layerRect.area < $1.layerRect.area }) else {
                return
            }

            previewView?.showSelection(selectedItem.layerRect)
            parent.onTextFound(selectedItem.text)
        }

        private func configureAndStartSession() {
            sessionQueue.async { [weak self] in
                guard let self else { return }

                if !isConfigured {
                    configureSession()
                }

                if isConfigured, !session.isRunning {
                    session.startRunning()
                }
            }
        }

        private func configureSession() {
            session.beginConfiguration()
            session.sessionPreset = .high
            defer { session.commitConfiguration() }

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                return
            }

            session.addInput(input)
            captureDevice = device

            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]
            videoOutput.setSampleBufferDelegate(self, queue: visionQueue)

            guard session.canAddOutput(videoOutput) else { return }
            session.addOutput(videoOutput)
            videoOutput.connection(with: .video)?.videoRotationAngle = 90
            isConfigured = true
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard isTextRecognitionEnabled else { return }
            guard !isProcessingFrame else { return }

            let now = Date()
            guard now.timeIntervalSince(lastRecognitionDate) > 0.45 else { return }

            isProcessingFrame = true
            lastRecognitionDate = now

            let request = VNRecognizeTextRequest { [weak self] request, error in
                defer { self?.isProcessingFrame = false }

                if let error {
                    print("Text recognition failed: \(error)")
                    return
                }

                guard let self,
                      let observations = request.results as? [VNRecognizedTextObservation] else { return }

                DispatchQueue.main.async {
                    self.updateRecognizedItems(from: observations)
                }
            }

            request.recognitionLevel = .fast
            request.usesLanguageCorrection = false

            let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .right)
            do {
                try requestHandler.perform([request])
            } catch {
                isProcessingFrame = false
                print("Unable to perform text recognition: \(error)")
            }
        }

        @MainActor
        private func updateRecognizedItems(from observations: [VNRecognizedTextObservation]) {
            guard let previewView else { return }

            let newItems = observations.compactMap { observation -> RecognizedTextItem? in
                guard let candidate = observation.topCandidates(1).first else { return nil }
                let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return nil }

                let metadataRect = CGRect(
                    x: observation.boundingBox.minX,
                    y: 1 - observation.boundingBox.maxY,
                    width: observation.boundingBox.width,
                    height: observation.boundingBox.height
                )
                let layerRect = previewView.videoPreviewLayer
                    .layerRectConverted(fromMetadataOutputRect: metadataRect)
                    .standardized
                    .insetBy(dx: -3, dy: -3)

                guard layerRect.width > 12, layerRect.height > 8 else { return nil }
                return RecognizedTextItem(text: text, layerRect: layerRect, confidence: candidate.confidence)
            }

            recognizedItems = newItems
            previewView.updateHighlights(newItems)
        }
    }
}

private extension CGRect {
    var area: CGFloat {
        width * height
=======
        var isStarting = false
        
        init(_ parent: DataScannerView) { self.parent = parent }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .text(let text) = item {
                parent.onTextFound(text.transcript)
            }
        }
>>>>>>> parent of dbf7370 (Saturday 23rd May 2026; 4:55pm)
    }
}
