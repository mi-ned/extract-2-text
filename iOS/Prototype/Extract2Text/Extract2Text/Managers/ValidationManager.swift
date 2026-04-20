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
        
        var displayMessage: LocalizedStringResource {
            switch self {
                case .validEAN(let code):
                    return LocalizedStringResource("card_ui.output_box.valid_ean \(code)")
                case .validTPBN(let code):
                    return LocalizedStringResource("card_ui.output_box.valid_tpbn \(code)")
                case .invalidEAN:
                    return LocalizedStringResource("card_ui.output_box.invalid_ean")
                case .invalidData:
                    return LocalizedStringResource("card_ui.output_box.invalid_data")
                }
        }
        
        var isSuccess: Bool {
            switch self {
                case .validEAN, .validTPBN: return true
                default: return false
            }
        }
    }
    
    func validateData(scannedText: String) -> ScanResult? {
        let processedData = scannedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !processedData.isEmpty else { return nil }
        
        //TPBN: 6 to 9 digits
        if processedData.wholeMatch(of: #/\d{6,9}/#) != nil {
            return .validTPBN(processedData)
        }
        
        //EAN: exactly 13 digits
        if processedData.wholeMatch(of: #/\d{13}/#) != nil {
            return isValidEAN13(processedData) ? .validEAN(processedData) : .invalidEAN
        }
        
        //Invalid data
        return .invalidData
    }
    
    private func isValidEAN13(_ code: String) -> Bool {
        guard code.count == 13, code.allSatisfy(\.isNumber) else { return false }
        
        let digits = code.compactMap { $0.wholeNumberValue }
        let checkDigit = digits.last
        
        let sum = digits.dropLast().enumerated().reduce(0) { total, next in
            total + (next.offset % 2 == 1 ? next.element * 3: next.element)
         }

        let calculatedCheck = (10 - (sum % 10)) % 10
        return checkDigit == calculatedCheck
    }
}
