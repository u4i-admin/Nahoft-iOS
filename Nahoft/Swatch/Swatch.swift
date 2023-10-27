//
//  Swatch.swift
//  Nahoft
//
//  Created by Sadra Sadri on 4.08.2023.
//

import Foundation

class Swatch {
    static let lengthMessageKey = 1
    static let payloadMessageKey = 2
    static let minimumPatchSize = 400
    // 1,000 characters * 4 bytes per character (as a guess) * number of bits in a byte
    static let maxMessageSizeBits = 1000 * 4 * 8
    
    static func polish(data: [UInt8], key: Int) -> [UInt8] {
        var result: [UInt8] = []
        
        for val in data {
            let dataInt = Int(val)
            let entropyInt = Int(arc4random_uniform(UInt32(key)))
            let resultInt = dataInt ^ entropyInt
            result.append(UInt8(resultInt))
        }

        return result
    }
    
    static func bitsFromBytes(bytes: [UInt8]) -> [Int]
    {
        var result: [Int] = Array<Int>(repeating: 0, count: bytes.count * 8)

        for byteIndex in 0..<bytes.count
        {
            let byte = UInt8(bytes[byteIndex])

            for bitIndex in 0..<8
            {
                let arrayIndex = byteIndex * 8 + bitIndex
                let bit = byte & masks[bitIndex]

                if bit == 0
                {
                    result[arrayIndex] = 0
                }
                else
                {
                    result[arrayIndex] = 1
                }
            }
        }

        return result
    }
    
    static func bytesFromBits(bits: [Int]) -> [UInt8]?
    {
        if bits.count % 8 != 0 { return nil }
        var result = [UInt8](arrayLiteral: unsafeBitCast(bits.count / 8, to: UInt8.self))
        for byteIndex in 0..<result.count
        {
            var byte: UInt8 = 0
            for bitIndex in 0..<8
            {
                let arrayIndex = byteIndex * 8 + bitIndex
                let value = bits[arrayIndex]
                if value == 0
                {
                    continue
                }
                else if (value == 1)
                {
                    let maskValue: UInt8 = masks[bitIndex]
                    byte = (byte + maskValue)
                }
                else
                {
                    return nil
                }
            }

            result[byteIndex] = byte
        }

        return result
    }
}
