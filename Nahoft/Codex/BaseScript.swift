//
//  BaseScript.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import Foundation
import BigInt

public class BaseScript {
    var wordList: Array<String> = WordListA.wordList + WordListB.wordList
    
    public func checkAlphabet() -> Bool {
        for letter in wordList {
            var index = -1
            var offset = 0
            
            for letter2 in wordList {
                if (letter == letter2) {
                    if (index == -1) {
                        index = offset
                    } else {
                        print("failure: " + String(index) + " " + String(offset))
                        return false
                    }
                }
                
                offset += 1
            }
        }
        
        return true
    }
    
    // takes a string of words with spaces in them, breaks them up into individual word
    // removing the spaces, then looks up each word in word list and gives the index and
    // returns a list of the index
    func symbolToDigits(ciphertext: String) -> Array<Int> {
        var digits: Array<Int> = []
        let noSpace = ciphertext.components(separatedBy: " ")
        for word in noSpace {
            if let foundIndex = wordList.firstIndex(of: word) {
                digits.append(foundIndex)
            } else {
                return [];
            }
        }
        return digits
    }
    
    func bigIntegerToDigits(integer: BigInt, base: Int) -> Array<Int> {
        if integer == 0 {
            return [0]
        }
        var result: Array<Int> = []
        let numDigits = computeNumDigits(integer: integer, base: base)
        let placeValues = generatePlaceValues(numDigits: numDigits, base: base)
        //print("placeValues: " + placeValues)
        
        var working = integer
        for placeValue in placeValues {
            let digit = working / placeValue
            working %= placeValue
            //print(" " + placeValue + " * " + digit + " + ")
            result.append(Int(digit))
        }
        
        while result[0] == 0 {
            result.removeFirst()
        }
        
        return result
    }
    
    func digitsToBigInteger(digits: Array<Int>, base: Int) -> BigInt {
        let numDigits = digits.count
        let placeValues = generatePlaceValues(numDigits: numDigits, base: base)
//        print("placeValues: " + String(from: placeValues)
        return computeInteger(placeValues: placeValues, digits: digits)
    }
    
    func bytesToDigits(bytes: Array<UInt8>) -> Array<Int> {
        var results: Array<Int> = []
        for byte in bytes {
            var result: Int
            result = Int(byte)

            assert(result >= 0)
            assert(result <= 255)
            //print("Input: " + String(byte))
            //print("Output: " + String(result))

            results.append(result)
        }

        return results
    }
    
    func digitsToBytes(digits: Array<Int>) -> Array<UInt8> {
        var result: Array<UInt8> = []
        for digit in digits {
            assert(digit >= 0)
            assert(digit <= 255)

            result.append(UInt8(digit))
        }
        let _ : [Int8] = (result.map { Int8(bitPattern: $0) })
        //print(intArray)
        return result
    }
    
    // takes a series of digits, looks it up in the word list and gives back a string of words
    func digitsToSymbols(digits: Array<Int>) -> String {
        var result: String = ""

        for digit in digits {
            let word = wordList[Int(digit)]
            result = result + word + " "
        }
        //print("symbol: " + result)

        return result.trimmingCharacters(in: .whitespaces)
    }
    
    func generatePlaceValues(numDigits: Int, base: Int) -> Array<BigInt> {
        var placeValues: Array<BigInt> = []
        for index in 0...numDigits - 1 {
            let place = (numDigits - 1) - index
            let placeValue = generatePlaceValue(place: place, base: base)
            placeValues.append(placeValue)
        }

        return placeValues
    }
    
    func generatePlaceValue(place: Int, base: Int) -> BigInt {
        var placeValue: BigInt = 1
        if place <= 0 { return 1 }
        for _ in 1...place {
            placeValue = BigInt(base) * placeValue
        } // BigInt(pow(Double(base), Double(place)))
        //print(placeValue)
        return placeValue
    }
    
    func computeInteger(placeValues: Array<BigInt>, digits: Array<Int>) -> BigInt {
        var working: BigInt = 0

        digits.indices.forEach { index in
            let digit = BigInt(digits[index])
            let placeValue = placeValues[index]
            let value: BigInt = digit * placeValue
            working += value

            //print(" " + placeValue + " * " + digit + " + ")
        }

        return working
    }
    
    func computeNumDigits(integer: BigInt, base: Int) -> Int {
        let bigBase = BigInt(base)
        if integer < bigBase {
            return 1
        }

        var place = 1
        var placeValue = bigBase
        while (integer > placeValue)
        {
            place += 1
            placeValue = generatePlaceValue(place: place, base: base)
        }

        if (integer == placeValue)
        {
            return place + 1
        }
        else
        {
            return place
        }
    }
}
