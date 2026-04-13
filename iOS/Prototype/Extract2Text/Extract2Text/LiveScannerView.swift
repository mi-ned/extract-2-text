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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            cameraLayer
            
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
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
    }
        
        @ViewBuilder
        private var cameraLayer: some View {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerView { scannedText in
                    viewModel.processScan(scannedText: scannedText)
                }
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                Text(String(localized: "main.camera.not_supported"))
                    .foregroundColor(.red)
            }
        }
        
        private var timerBarView: some View {
            //TimelineView(.animation) { timeline in
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    //Glass
                    Capsule().fill(Color.utility).frame(height: 8)
                    //Sand
                    Capsule()
                        .fill(Color.foreground)
                        .frame(width: geo.size.width * CGFloat(viewModel.timeRemaining / AppConfig.timerDurationInSeconds), height: 8)
                        .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
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
    }
