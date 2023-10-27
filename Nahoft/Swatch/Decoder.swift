//
//  Decoder.swift
//  Nahoft
//
//  Created by Sadra Sadri on 4.08.2023.
//

import Foundation
import CoreGraphics
import UIKit

class Decoder {
//    func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int)
//    {
//        var width = 0
//        var height = 0
//        var pixelValues: [UInt8]?
//        if let imageRef = imageRef {
//            width = imageRef.width
//            height = imageRef.height
//            let bitsPerComponent = imageRef.bitsPerComponent
//            let bytesPerRow = imageRef.bytesPerRow
//            let totalBytes = height * bytesPerRow
//
//            let colorSpace = CGColorSpaceCreateDeviceGray()
//            var intensities = [UInt8](repeating: 0, count: totalBytes)
//
//            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
//            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
//
//            pixelValues = intensities
//        }
//
//        return (pixelValues, width, height)
//    }

//    func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?
//    {
//        var imageRef: CGImage?
//        if var pixelValues = pixelValues {
//            let bitsPerComponent = 8
//            let bytesPerPixel = 1
//            let bitsPerPixel = bytesPerPixel * bitsPerComponent
//            let bytesPerRow = bytesPerPixel * width
//            let totalBytes = height * bytesPerRow
//
//            imageRef = withUnsafePointer(to: &pixelValues, {
//                ptr -> CGImage? in
//                var imageRef: CGImage?
//                let colorSpaceRef = CGColorSpaceCreateDeviceGray()
//                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
//                let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
//                let releaseData: CGDataProviderReleaseDataCallback = {
//                    (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
//                }
//
//                if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
//                    imageRef = CGImage(width: width,
//                                       height: height,
//                                       bitsPerComponent: bitsPerComponent,
//                                       bitsPerPixel: bitsPerPixel,
//                                       bytesPerRow: bytesPerRow,
//                                       space: colorSpaceRef,
//                                       bitmapInfo: bitmapInfo,
//                                       provider: providerRef,
//                                       decode: nil,
//                                       shouldInterpolate: false,
//                                       intent: CGColorRenderingIntent.defaultIntent)
//                }
//
//                return imageRef
//            })
//        }
//
//        return imageRef
//    }
    
    func pixelData(image: UIImage) -> [UInt8]? {
        let size = image.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = image.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return pixelData
    }
    
    func decode(image: UIImage) -> [UInt8]? {
        let bitmap = image.size
        let numPixels: Int = Int(bitmap.height * bitmap.width)
        let lengthInBits = numPixels / (Swatch.minimumPatchSize * 2)
        let lengthInBytes = lengthInBits / 8
        let roundedLengthInBits = lengthInBytes * 8
        let messageBits = decode(bitmap: image, size: roundedLengthInBits, messageSeed: Swatch.payloadMessageKey)
        if messageBits == nil { return nil }
        return Swatch.bytesFromBits(bits: messageBits!)
    }
    
    func decode(bitmap: UIImage, size: Int, messageSeed: Int) -> [Int]?
    {
        let numberOfPixels = bitmap.size.height * bitmap.size.width
        let patchSize = Int(numberOfPixels) / (size*2)

        if (patchSize < Swatch.minimumPatchSize) { return nil }

        // Randomly map the pixels
        // Make an array of integers 0 - numberOfPixels and shuffle it
        let mapped = MappedBitmap(bitmap: bitmap, key: messageSeed)

        var message: [Int] = Array(repeating: 0, count: size)

        for index in 0..<size
        {
            let detector = Detector(index: index, patchSize: patchSize, mapped: mapped)
            
            switch detector.constraint {
            case .Greater:
                message[index] = 1
            case .Less:
                message[index] = 0
            case .Equal:
                return nil
            }
        }

        return message
    }
}
