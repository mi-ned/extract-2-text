//
//  ValidationService.swift
//  Extract2Text
//
//  Created by Miroslav Nedeljkovic on 27/03/2026.
//

import SwiftUI
import Combine

struct ValidationService {
    enum ScanResult: Equatable {
        case validEAN(String)
        case validTPBN(String)
        case invalidEAN
        case invalidData
        case none
    }
    
    func validateData(scannedText: String) -> ScanResult {
        let processedData = scannedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if processedData.range(of: "^\\d{6,9}$", options: .regularExpression) != nil {
            return .validTPBN(processedData)
        }
        
        let is13Digits = processedData.range(of: "^\\d{13}$", options: .regularExpression) != nil
        if is13Digits {
            return isValidEAN13(processedData) ? .validEAN(processedData) : .invalidEAN
        }
        
        return .invalidData
    }
    
    private func isValidEAN13(_ code: String) -> Bool {
        guard code.count == 13, let _ = Int64(code) else { return false }
        let digits = code.compactMap { Int(String($0)) }
        var sum = 0
        for i in 0..<12 {
            sum += (i % 2 == 0) ? digits[i] : digits[i] * 3
        }
        let checkDigit = (10 - (sum % 10)) % 10
        return checkDigit == digits[12]
    }
}
