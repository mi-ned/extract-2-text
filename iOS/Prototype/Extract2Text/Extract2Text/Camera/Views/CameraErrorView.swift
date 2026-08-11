//
//  CameraErrorView.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 03/06/2026.
//

import SwiftUI

struct CameraErrorView: View {
    
    var body: some View {
        VStack {
            Text("main.camera.not_supported", comment: "Displayed when camera initialision fails")
                .foregroundStyle(Color("ForegroundColor"))
                .font(.system(.headline, design: .monospaced))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
