//
//  Patch.swift
//  Nahoft
//
//  Created by Sadra Sadri on 4.08.2023.
//

import Foundation

class Patch {
    var patchIndex: Int
    var size: Int
    var bitmap: MappedBitmap
    var pixels: Array<Pixel> = []
    var pixelsToModify: Array<Pixel>
    var brightness: Int
    
    init(patchIndex: Int, size: Int, bitmap: MappedBitmap) {
        self.patchIndex = patchIndex
        self.size = size
        self.bitmap = bitmap
        brightness = 0
        for index in 0..<size {
            let pixelIndex = patchIndex * size + index
            let mappedPixelIndex = bitmap.mapping[pixelIndex]
            let pixel = Pixel(index: mappedPixelIndex, bitmap: bitmap)
            brightness += pixel.brightness()
            pixels.append(pixel)
        }
        pixelsToModify = pixels
    }
    
    func modifyBrightness(direction: EncoderConstraint, targetChangeInBrightness: Int) -> Int {
        var achievedChangeInBrightness = 0
        if targetChangeInBrightness == 0 {
            // Success! Achieved target change in brighhtness of 0.
            return achievedChangeInBrightness
        }

        var patchBrightnessDifferencePerPixel = targetChangeInBrightness / pixelsToModify.count
        if (patchBrightnessDifferencePerPixel == 0) {
            // Deal with rounding to 0
            patchBrightnessDifferencePerPixel = 1
        }

        while (achievedChangeInBrightness < targetChangeInBrightness) {
            var unchangeablePixels: Array<Int> = []

            if (pixelsToModify.count == 0)
            {
                // Failure or partial success. Did not achieve target change in brightness and ran out of pixels to modify.
                return achievedChangeInBrightness
            }

            // Iterate though all of the pixels which we are allowed to change.
            for index in pixelsToModify.indices {
                // Picks a random pixel from the patch changes the color of the pixel to be darker
                let changeInBrightness: Int
                switch direction {
                case .Greater:
                    changeInBrightness = pixelsToModify[index].brighten(targetChangeInBrightness: patchBrightnessDifferencePerPixel)
                case .Less:
                    changeInBrightness = pixelsToModify[index].darken(targetChangeInBrightness: patchBrightnessDifferencePerPixel)
                }

                if (changeInBrightness == 0) {
                    unchangeablePixels.insert(index, at: 0)
                } else {
                    achievedChangeInBrightness += changeInBrightness
                    switch direction {
                    case .Greater:
                        brightness += changeInBrightness
                    case .Less:
                        brightness -= changeInBrightness
                    }

                    // Check if we can escape early from iterating through all of the pixels.
                    if (achievedChangeInBrightness >= targetChangeInBrightness) {
                        return achievedChangeInBrightness
                    }
                }
            }

            // Remove all of the pixel that we can't change to save time through the next iteration.
            for unPixel in unchangeablePixels {
                pixelsToModify.remove(at: unPixel)
            }
        }

        // Success! Achieved targeted change in brightness, as indicated by leaving the main loop.
        return achievedChangeInBrightness
    }
}
