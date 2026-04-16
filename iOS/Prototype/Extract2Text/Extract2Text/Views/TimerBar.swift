//
//  TimerBar.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 16/04/2026.
//

import SwiftUI
import VisionKit
import Combine

struct TimerBar: View {
    let timerProgress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                //Glass
                Capsule().fill(Color.utility).frame(height: 8)
                //Sand
                Capsule()
                    .fill(Color.foreground)
                    .frame(width: geo.size.width * CGFloat(timerProgress), height: 8)
            }
        }
        .frame(height: 8)
        .animation(.interactiveSpring(), value: timerProgress)
    }
}
