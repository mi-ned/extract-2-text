//
//  CameraState.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 01/07/2026.
//

import Foundation

public enum CameraState: Sendable {
    case idle
    case active
    case unauthorized
    case error
    case restricted
}
