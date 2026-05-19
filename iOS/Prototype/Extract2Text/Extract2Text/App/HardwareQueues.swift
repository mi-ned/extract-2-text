//
//  HardwareQueues.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 19/05/2026.
//

import Foundation

struct HardwareQueues {
    static let serialAccessQueue = DispatchQueue(label: "com.extract2text.hardware.serial")
}
