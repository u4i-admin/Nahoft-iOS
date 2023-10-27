//
//  MappedBitmap.swift
//  Nahoft
//
//  Created by Sadra Sadri on 4.08.2023.
//

import Foundation
import UIKit

class MappedBitmap {
    var mapping: [Int] = []
    var bitmap: UIImage
    var imageData: [UInt8]
    
    init(bitmap: UIImage, key: Int) {
        self.bitmap = bitmap
        let imgData = Decoder().pixelData(image: bitmap)
        if let imgData {
            self.imageData = imgData
        } else {
            self.imageData = []
        }
        let numberOfPixels = Int(bitmap.size.height * bitmap.size.width)
        var random = RandomNumberGeneratorWithSeed(seed: key)
        for index in 0..<numberOfPixels {
            mapping.append(index) 
        }
        mapping.shuffle(using: &random)
    }
    
    func getPixel(index: Int) -> [UInt8] {
        var result: [UInt8] = []
        for i in index...index+3 {
            result.append(imageData[i])
        }
        
        return result
    }

    func setPixel(index: Int, color: [UInt8]) {
        for i in 0...3 {
            imageData[index+i] = color[i]
        }
    }
    
    struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
        init(seed: Int) { srand48(seed) }
        func next() -> UInt64 { return UInt64(drand48() * Double(UInt64.max)) }
    }
}
