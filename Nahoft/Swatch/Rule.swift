//
//  Rule.swift
//  Nahoft
//
//  Created by Sadra Sadri on 9.08.2023.
//

import Foundation

class Rule {
    var ruleIndex: Int
    var patchSize: Int
    var constraint: EncoderConstraint
    var bitmap: MappedBitmap
    
    var patch0: Patch
    var patch1: Patch

    var valid: Bool
    var brightnessGap: Int
    
    init(ruleIndex: Int, patchSize: Int, constraint: EncoderConstraint, bitmap: MappedBitmap) {
        self.ruleIndex = ruleIndex
        self.patchSize = patchSize
        self.constraint = constraint
        self.bitmap = bitmap
        
        patch0 = Patch(patchIndex: ruleIndex * 2, size: patchSize, bitmap: bitmap)
        patch1 = Patch(patchIndex: (ruleIndex * 2) + 1, size: patchSize, bitmap: bitmap)

        switch (constraint) {
        case .Greater: valid = patch0.brightness > patch1.brightness
        case .Less: valid = patch0.brightness < patch1.brightness
        }

        if (valid) {
            brightnessGap = 0
        } else if (patch0.brightness == patch1.brightness) {
            brightnessGap = 1
        } else {
            // Neither valid nor equal, the validity condition must be inverted.
            brightnessGap = abs(patch0.brightness - patch1.brightness) + 1
        }
    }
    
    // Does this pair of patches meet the constraint
    func validate() -> Bool {
        switch (constraint) {
        case .Greater: valid = patch0.brightness > patch1.brightness
        case .Less: valid = patch0.brightness < patch1.brightness
        }

        if (valid) {
            brightnessGap = 0
        } else if (patch0.brightness == patch1.brightness) {
            brightnessGap = 1
        } else {
            // Neither valid nor equal, the validity condition must be inverted.
            brightnessGap = abs(patch0.brightness - patch1.brightness) + 1
        }

        return valid
    }

    func constrain() -> Bool {
        // If the working bitmap is already valid, return it
        if (valid) {
            return true
        }

        return modifyBrightness()
    }

    func modifyBrightness() -> Bool {
        while (!validate()) {
            // Not valid, but no brightness gap? Weird, give up.
            if (brightnessGap == 0) {
                return false
            }

            // Divide the necessary work between the two patches
            var patchBrightnessGap = brightnessGap / 2
            if (patchBrightnessGap == 0) {
                // Deal with rounding to 0
                patchBrightnessGap = 1
            }

            let patch0Direction: EncoderConstraint
            switch (constraint) {
            case .Greater: patch0Direction = EncoderConstraint.Greater
            case .Less: patch0Direction = EncoderConstraint.Less
            }

            let patch1Direction: EncoderConstraint
            switch (constraint) {
            case .Greater: patch1Direction = EncoderConstraint.Less
            case .Less: patch1Direction = EncoderConstraint.Greater
            }

            let patch0Change = patch0.modifyBrightness(direction: patch0Direction, targetChangeInBrightness: patchBrightnessGap)
            let patch1Change = patch1.modifyBrightness(direction: patch1Direction, targetChangeInBrightness: patchBrightnessGap)

            if (patch0Change == 0 && patch1Change == 0) {
                // Failure. Did not achieve target brightness gap between patches and modifying patch brightness failed.
                return false
            }
        }

        // Success. Achieved target brightness gap between patches, as indicated by exiting the main loop.
        return true
    }
}
