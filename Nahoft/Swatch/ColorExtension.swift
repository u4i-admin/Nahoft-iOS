//
//  ColorExtension.swift
//  Nahoft
//
//  Created by Sadra Sadri on 8.08.2023.
//

import Foundation

class ColorExtension {
    static func redInt(rawData: [UInt8]) -> Int {
        return Int(CGFloat(rawData[0]) / 255.0)
    }
    
    static func greenInt(rawData: [UInt8]) -> Int {
        return Int(CGFloat(rawData[1]) / 255.0)
    }
    
    static func blueInt(rawData: [UInt8]) -> Int {
        return Int(CGFloat(rawData[2]) / 255.0)
    }
    
    static func alphaInt(rawData: [UInt8]) -> Int {
        return Int(CGFloat(rawData[3]) / 255.0)
    }
    
    static func brightness(rawData: [UInt8]) -> Int {
        return (redInt(rawData: rawData) + greenInt(rawData: rawData) + blueInt(rawData: rawData)) / 3
    }
    
    static func getUInt8(data: Int) -> UInt8 {
        return UInt8(data)
    }
}
