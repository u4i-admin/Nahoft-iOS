//
//  WordScript.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import Foundation
import Sodium

class WordScript: BaseScript {
    func encode(bytes: Bytes) -> String {
        let byteDigits = bytesToDigits(bytes: bytes)
        //print("bytes: " + byteDigits)
        
        let integer = digitsToBigInteger(digits: byteDigits, base: 256)
        //print("integer: " + String(from: integer))
        
        let digits = bigIntegerToDigits(integer: integer, base: wordList.count)
        //print("digits: " + digits)
        
        // takes a series of digits, looks it up in the word list and gives back a string of words
        return digitsToSymbols(digits: digits)
    }
    
    func decode(ciphertext: String) -> Bytes {
        let base = wordList.count
        
        let digits = symbolToDigits(ciphertext: ciphertext)
        //print("digits: " + digits)
        if digits.isEmpty { return [] }
        let integer = digitsToBigInteger(digits: digits, base: base)
        //print("integer: " + String(from: integer))
        
        let byteDigits = bigIntegerToDigits(integer: integer, base: 256)
        //print("bytes: " + byteDigits)
        
        let bytes = digitsToBytes(digits: byteDigits)
        return bytes
    }
}
