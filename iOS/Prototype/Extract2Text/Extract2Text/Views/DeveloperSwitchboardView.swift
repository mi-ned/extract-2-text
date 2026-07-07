//
//  DeveloperSwitchboardView.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 07/07/2026.
//

import SwiftUI

#if DEBUG
struct DeveloperSwitchboardView: View {
    @Bindable var viewModel: ContentViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Hardware Simulation Faults")) {
                    Button(role: .destructive, action: {
                        viewModel.simulateHardwareFailure()
                        dismiss()
                    }) {
                        Label("Trigger Camera Runtime Error", systemImage: "bolt.trianglebadge.exclamationmark")
                    }
                }
            }
            .navigationTitle("Dev Switchboard")
            .toolbar {
                Button("Close") { dismiss() }
            }
        }
    }
}
#endif
