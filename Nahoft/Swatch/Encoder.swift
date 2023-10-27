//
//  Encoder.swift
//  Nahoft
//
//  Created by Sadra Sadri on 9.08.2023.
//

import Foundation
import UIKit

class Encoder {
    func encode(encrypted: [UInt8], cover: UIImage, saveToGallery: Bool) -> UIImage?
    {
        let result = encode(encrypted: encrypted, cover: cover)
//        let title = ""
//        let description = ""

        guard let result = result else { return nil }

        if (saveToGallery)
        {
            print(result.size.width)
            print(result.size.height)
            
            UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
            return result
        }
        else
        {
            return result //CapturePhotoUtils.insertImage(result, title, description)
        }
    }
    
//    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        print("Save finished!")
//    }

    func encode(encrypted: [UInt8], cover: UIImage) -> UIImage?
    {
        var workingCover = cover

        // Convert message size from bytes to bits
        // Pad the message bits to be of max size
        let messageBits = Swatch.bitsFromBytes(bytes: encrypted)
        let messageBitsSize = messageBits.count

        // Scale the image if necessary
        workingCover = scale(bitmap: cover, bits: messageBitsSize)

        // The number of pixels is the image height (in pixels) times the image width (in pixels)
        let numPixels = workingCover.size.height * workingCover.size.width

        // Do we have enough pixels for the bits we need to encode?
        let messagePatchSize = Int(numPixels) / (messageBitsSize * 2)

        if (messagePatchSize < Swatch.minimumPatchSize) {
            return nil
        }

        //let result = workingCover.copy(Bitmap.Config.ARGB_8888, true)
        return encode(cover: workingCover, message: messageBits)
    }

    // Takes both messages (length message, and message message) as bits and the bitmap we want to put them in
    func encode(cover: UIImage, message: [Int]) -> UIImage? {
        let rules = makeRules(cover: cover, message: message, key: Swatch.payloadMessageKey)
        guard let rules = rules else { return nil }

        let solver = Solver(coverImageBitmap: cover, messageARules: rules)
        let success = solver.constrain()
        if (!success) {
            return nil
        }

        return cover
    }

    func scale(bitmap: UIImage, bits: Int) -> UIImage {
        var p = bits * 2 * Swatch.minimumPatchSize
        let size = bitmap.size.height * bitmap.size.width
        if (Int(size) == p) {
            return bitmap
        } else {
            let originalSize = CGSize(
                width: Double(bitmap.size.width),
                height: Double(bitmap.size.height)//,
                //32.0 //ARGB_8888 8 bits for each in ARGB added together
            )

            var scaledSize = resizePreservingAspectRatio(originalSize: originalSize, targetSizePixels: p)
            var newHeight = Int(scaledSize.height)
            var newWidth = Int(scaledSize.width)
            var newNumPixels = newHeight * newWidth
            var newBits = newNumPixels / (Swatch.minimumPatchSize * 2)
            while (newBits < bits) {
                print("Error in scaling algorithm.")
                p += 1
                scaledSize = resizePreservingAspectRatio(originalSize: originalSize, targetSizePixels: p)
                newHeight = Int(scaledSize.height)
                newWidth = Int(scaledSize.width)
                newNumPixels = newHeight * newWidth
                newBits = newNumPixels / (Swatch.minimumPatchSize * 2)
            }
            let newBitmap = bitmap.imageResized(to: CGSize(width: newWidth, height: newHeight))// bitmap.scale() Bitmap.createScaledBitmap(
//                bitmap,
//                newHeight,
//                newWidth,
//                true
//            )

            return newBitmap
        }
    }

    private func resizePreservingAspectRatio(originalSize: CGSize, targetSizePixels: Int) -> CGSize {
        let aspectRatio = originalSize.height / originalSize.width
        let scaledHeight = sqrt(Double(targetSizePixels / Int(aspectRatio)))
        let scaledWidth = aspectRatio * scaledHeight

        return  CGSize(width: scaledWidth, height: scaledHeight) //, originalSize.colorDepthBytes)
    }

    /// Generates an array of rules.
    /// Each rule returns 2 patches and a constraint (whether or not they are lighter or darker than each other)
    /// Greater is a 1
    /// Less is a 0
    func makeRules(cover: UIImage, message: [Int], key: Int) -> Array<Rule>?
    {
        let numPixels = cover.size.height * cover.size.width

        // Each bit needs a pair of patches
        let patchSize = Int(numPixels) / (message.count * 2)

        let mapped = MappedBitmap(bitmap: cover, key: key)

        var rules: Array<Rule> = []

        // For each bit in the message we get a rule
        // A rule is two patches and a constraint
        for index in message.indices
        {
            let bit = message[index]

            // Does patchA need to be lighter than patchB, or darker?
            // Brightness is based on the average brightness for the entire patch.
            let constraint: EncoderConstraint?
            switch (bit) {
            case 1: constraint = .Greater
            case 0: constraint = .Less
            default:
                constraint = nil
            }

            guard let constraint = constraint else {
                return nil
            }

            let rule = Rule(ruleIndex: index, patchSize: patchSize, constraint: constraint, bitmap: mapped)
            rules.append(rule)
        }

        return rules
    }
}
