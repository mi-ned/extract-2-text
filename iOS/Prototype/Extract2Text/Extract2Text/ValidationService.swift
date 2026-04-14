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
        
        var displayMessage: String {
            switch self {
            case .validEAN(let code):
                let format = NSLocalizedString("card_ui.output_box.valid_ean", comment: "")
                return String.localizedStringWithFormat(format, code)
            case .validTPBN(let code):
                let format = NSLocalizedString("card_ui.output_box.valid_tpbn", comment: "")
                return String.localizedStringWithFormat(format, code)
            case .invalidEAN: 
                return NSLocalizedString("card_ui.output_box.invalid_ean", comment: "")
            case .invalidData:
                return NSLocalizedString("card_ui.output_box.invalid_data", comment: "")
            }
        }
        
        var isSuccess: Bool {
            if case .validEAN = self { return true }
            if case .validTPBN = self { return true }
            return false
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
        
        let digits = code.compactMap { Int(String($0)) }
        guard code.count == 13 else { return false }
        
        let sum = digits.enumerated().prefix(12).reduce(0) { acc, next in
            acc + (next.offset % 2 == 0 ? next.element : next.element * 3)
         }

        let checkDigit = (10 - (sum % 10)) % 10
        return checkDigit == digits[12]
    }
}
