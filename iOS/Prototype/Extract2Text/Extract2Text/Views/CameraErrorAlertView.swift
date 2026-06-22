//
//  CameraErrorAlertView.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 03/06/2026.
//

import SwiftUI

struct CameraErrorAlertView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            
            Color("BackgroundColor").opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0){
                Text("main.camera.not_supported", comment: "Error header")
                    .font(.headline)
                    .padding(.top,20)
                    .padding(.bottom,20)
                    
                Text("main.camera.not_supported_message", comment: "Error message")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                Divider()
                    
                    HStack(spacing: 0) {
                        Button("alert.button.settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundColor(.blue)
                        .font(.system(.body, weight: .regular))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        
                        Divider()
                            .frame(height: 48)
                        
                        Button("alert.button.ok"){
                            onDismiss()
                        }
                        .foregroundColor(.blue)
                        .font(.system(.body, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                    }
                }
                .frame(maxWidth: 300)
                .minimumScaleFactor(0.5)
                .background(.ultraThinMaterial)
                .cornerRadius(14)
            }
        }
    }
