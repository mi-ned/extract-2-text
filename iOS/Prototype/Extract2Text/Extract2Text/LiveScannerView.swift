//
//  Untitled.swift
//  Text2Text_prototype
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import SwiftUI
import VisionKit
import Combine

struct LiveScannerView: View {
    
    @StateObject private var viewModel = LiveScannerViewModel() //N
    @Environment(\.scenePhase) var scenePhase
    
    //@State var timerDurationInSeconds: Double = AppConfig.timerDurationInSeconds
    //@State private var timeRemaining: Double = 0.0
    //@State private var expirationDate: Date? = nil
    
    //private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    //@State private var outputBoxMessage: String = String(localized: "card_ui.output_box.scan_code");
    
    /*private var statusMessage: LocalizedStringKey {
        
        if(timeRemaining > 0){
            return LocalizedStringKey("card_ui.status_message.clearing_clipboard \(Int(ceil(timeRemaining)))")
        } else {
            return ""
        }
    }*/
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Camera
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                
                DataScannerView { scannedText in
                    viewModel.processScan(scannedText: scannedText)
                }
                .ignoresSafeArea()
            }
            else {
                Color.black.ignoresSafeArea()
                Text(String(localized: "main.camera.not_supported"))
                    .foregroundColor(.red)
            }
                
            // Card UI
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    timerBarView
                    outputBoxMessageBoxView
                    statusMessageView
                    versionFooterView
                }
                .padding([.bottom, .top], 20)
                .padding(.horizontal, 16)
                .background(Color.tile)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        /*.onReceive(timer) { _ in
            guard scenePhase == .active, let expiration = expirationDate else { return }
            let now = Date()
            
            if now >= expiration {
                outputBoxMessage = String(localized: "card_ui.output_box.clipboard_cleared")
                UIPasteboard.general.string = ""
                expirationDate = nil
                timeRemaining = 0
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            } else {
                timeRemaining = expiration.timeIntervalSince(now)
            }
        }*/
        .onChange(of: viewModel.outputBoxMessage) { _, newVal in
            viewModel.handleScanChange(newVal: newVal)
            /*if newVal.contains("Valid") {
                expirationDate = Date().addingTimeInterval(timerDurationInSeconds)
                timeRemaining = timerDurationInSeconds
            }*/
        }
        /*onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                viewModel.forceExpiry()
            }
        }*/
        .onAppear {
            viewModel.clearClipboard()
        }
    }
    
    private var timerBarView: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    //Glass
                    Capsule()
                        .fill(Color.utility)
                        .frame(height: 8)
                    //Sand
                    Capsule()
                        .fill(Color.foreground)
                        .frame(width: fluidWidth(in: geo, at: timeline.date), height: 8)
                }
            }
        }
        .frame(height: 8)
    }
    
    private var outputBoxMessageBoxView: some View {
        Text(viewModel.outputBoxMessage)
            .font(.system(size: 17, weight: .regular))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.utility)
            .foregroundColor(Color.foreground)
            .cornerRadius(10)
    }
    
    private var statusMessageView: some View {
        Text(viewModel.statusMessage)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color.foreground.opacity(0.8))
            .frame(maxWidth: .infinity)
    }
    
    private var versionFooterView: some View {
        Text("card_ui.footer.version_label \(AppConfig.appName) \(AppConfig.appVersion)")
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(Color.foreground.opacity(0.6))
            .frame(maxWidth: .infinity)
    }
    
    private func fluidWidth(in geo: GeometryProxy, at currentDate: Date) -> CGFloat {
        guard let expiration = viewModel.expirationDate else { return 0 }
        
        let totalDuration = AppConfig.timerDurationInSeconds
        let remaining = expiration.timeIntervalSince(currentDate)
        
        let progress = max(0, min(1, remaining / totalDuration))
        return geo.size.width * CGFloat(progress)
    }
}
