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
