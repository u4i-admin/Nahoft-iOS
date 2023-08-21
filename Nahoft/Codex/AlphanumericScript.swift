//
//  AlphanumericScript.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import Foundation

class AlphanumericScript: BaseScript {
    let alphabet: Array<String> = [
        "۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹",
        "ی",
        "ء", "أ", "ئ", "ؤ", "ا", "ب", "پ", "ت", "ث", "ج", "چ", "ح", "خ", "د",
        "ذ", "ر", "ز", "ژ", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف", "ق",
        "ک", "گ", "ل", "م", "ن", "و", "ه"
    ]
    
    func encode(bytes: Array<UInt8>) -> String {
        let byteDigits = bytesToDigits(bytes: bytes)
        let integer = digitsToBigInteger(digits: byteDigits, base: 256)
        let digits = bigIntegerToDigits(integer: integer, base: alphabet.count)
        return digitsToSymbols(digits: digits)
    }

    func decode(ciphertext: String) -> Array<UInt8> {
        let base = alphabet.count
        let digits = symbolToDigits(ciphertext: ciphertext)
        let integer = digitsToBigInteger(digits: digits, base: base)
        let byteDigits = bigIntegerToDigits(integer: integer, base: 256)
        let bytes = digitsToBytes(digits: byteDigits)
        return bytes
    }
}
