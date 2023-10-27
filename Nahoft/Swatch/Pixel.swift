//
//  Pixel.swift
//  Nahoft
//
//  Created by Sadra Sadri on 4.08.2023.
//

import Foundation
import UIKit

class Pixel {
    var index: Int
    var bitmap: MappedBitmap
    
    init(index: Int, bitmap: MappedBitmap) {
        self.index = index
        self.bitmap = bitmap
    }
    
    func color() -> [UInt8] {
        bitmap.getPixel(index: index)
    }
    
    func brightness() -> Int
    {
        let color = bitmap.getPixel(index: index)
        return ColorExtension.brightness(rawData: color)
    }

    // Tries to increase the brightness by targetChanbgeInBrightness, returns actual change in brightness achieved.
    func brighten(targetChangeInBrightness: Int) -> Int
    {
        if (targetChangeInBrightness == 0) {
            // Success!
            return 0
        }

        var offsetAmount = targetChangeInBrightness * 3

        let colorData = bitmap.getPixel(index: index)
        let a: Int = ColorExtension.alphaInt(rawData: colorData)
        var r: Int = ColorExtension.redInt(rawData: colorData)
        var g: Int = ColorExtension.greenInt(rawData: colorData)
        var b: Int = ColorExtension.blueInt(rawData: colorData)

        // If any of the values are already 255 don't modify this pixel
        if (r == 255 || b == 255 || g == 255) { return 0 }

        // If the offsetAmount will cause any of the color values to exceed 255,
        // change the value to a number that will cause that color value to be exactly 255
        if ((r + offsetAmount) > 255)
        {
            offsetAmount = 255 - r
        }

        if ((g + offsetAmount) > 255)
        {
            offsetAmount = 255 - g
        }

        if ((b + offsetAmount) > 255)
        {
            offsetAmount = 255 - b
        }

        // Increase each color value by the settled on offsetAmount
        r += offsetAmount
        g += offsetAmount
        b += offsetAmount

        let oldBrightness = brightness()

        let newColor: [UInt8] = [ColorExtension.getUInt8(data: r), ColorExtension.getUInt8(data: g), ColorExtension.getUInt8(data: b), ColorExtension.getUInt8(data: a)]
        bitmap.setPixel(index: index, color: newColor)

        let newBrightness = brightness()

        return abs(newBrightness - oldBrightness)
    }

    // Tries to decrease the brightness by targetChanbgeInBrightness, returns actual change in brightness achieved.
    func darken(targetChangeInBrightness: Int) -> Int
    {
        if (targetChangeInBrightness == 0) {
            // Success!
            return 0
        }

        var offsetAmount = targetChangeInBrightness * 3

        let color = bitmap.getPixel(index: index)
        let a = ColorExtension.alphaInt(rawData: color)
        var r = ColorExtension.redInt(rawData: color)
        var g = ColorExtension.greenInt(rawData: color)
        var b = ColorExtension.blueInt(rawData: color)

        // If any of the values are already 0 don't modify this pixel
        if (r == 0 || b == 0 || g == 0) { return 0 }

        // If the offsetAmount will cause any of the color values to exceed 255,
        // change the value to a number that will cause that color value to be exactly 255
        if ((r - offsetAmount) < 0)
        {
            offsetAmount = r
        }

        if ((g - offsetAmount) < 0)
        {
            offsetAmount = g
        }

        if ((b - offsetAmount) < 0)
        {
            offsetAmount = b
        }

        // Increase each color value by the settled on offsetAmount
        r -= offsetAmount
        g -= offsetAmount
        b -= offsetAmount

        let oldBrightness = brightness()
        
        let newColor: [UInt8] = [ColorExtension.getUInt8(data: r), ColorExtension.getUInt8(data: g), ColorExtension.getUInt8(data: b), ColorExtension.getUInt8(data: a)]
        bitmap.setPixel(index: index, color: newColor)

        let newBrightness = brightness()

        return abs(newBrightness - oldBrightness)
    }
}
