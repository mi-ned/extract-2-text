//
//  Text2Text_prototypeApp.swift
//  Text2Text_prototype
//
//  Created by Miroslav Nedeljkovic on 01/03/2026.
//

import SwiftUI

@main
struct Extract2TextApp: App {
    @State private var contentViewModel = ContentViewModel()
    
    init() {
        _contentViewModel = State(initialValue: ContentViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: contentViewModel)
        }
    }
}
