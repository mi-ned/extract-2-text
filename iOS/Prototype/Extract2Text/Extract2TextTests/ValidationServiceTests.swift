//
//  ValidationServiceTests.swift
//  Extract2TextTests
//
//  Created by Miroslav Nedeljkovic on 27/03/2026.
//

import Testing
import Foundation
@testable import Extract2Text

@Suite("Validation Logic Tests")
struct ValidationServiceTests {
    let sut = ValidationService()
    
    @Test("Check that a valid EAN-13 passes",
          arguments: [
            "5449000000996",
            "9780131103627",
            "7622210444493"
          ])
    func validateEAN(code: String) {
        let result = sut.validateData(scannedText: code)
        #expect(result == .validEAN(code))
    }
    
    @Test("Check that a valid TPBN passes",
          arguments: [
            "123456789",
            "952584",
            "00000000"
          ])
    func validateTPBN(code: String) {
        let result = sut.validateData(scannedText: code)
        #expect(result == .validTPBN(code))
    }
    
    @Test("Check that an invalid EAN-13 fails",
          arguments: [
            "0000000000001",
            "5449000000997",
            "9780131103620"
          ])
    func validateFailedEAN(code: String) {
        let result = sut.validateData(scannedText: code)
        #expect(result == .invalidEAN)
    }
    
    @Test("Check that an invalid code fails",
          arguments: [
            "123",
            "1234567890",
            "12345",
            "12345678901234",
          ])
    func validateFailedData(code: String) {
        let result = sut.validateData(scannedText: code)
        #expect(result == .invalidData)
    }
    
    @Test("Check that an invalid format fails",
          arguments: [
            "abcdefu",
            ".",
            "999 999 999",
            "145-689-012"
          ])
    func validateFailedFormat(code: String) {
        let result = sut.validateData(scannedText: code)
        #expect(result == .invalidData)
    }
}
