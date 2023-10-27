//
//  Detector.swift
//  Nahoft
//
//  Created by Sadra Sadri on 4.08.2023.
//

import Foundation

class Detector {
    var index: Int
    var patchSize: Int
    var mapped: MappedBitmap
    var patch0: Patch
    var patch1: Patch
    var constraint: DecoderConstraint
    
    init(index: Int, patchSize: Int, mapped: MappedBitmap) {
        self.index = index
        self.patchSize = patchSize
        self.mapped = mapped
        
        patch0 = Patch(patchIndex: index * 2, size: patchSize, bitmap: mapped)
        patch1 = Patch(patchIndex: (index * 2) + 1, size: patchSize, bitmap: mapped)

        let b0 = patch0.brightness
        let b1 = patch1.brightness

        if b0 > b1 {
            constraint = .Greater
        } else if b0 < b1 {
            constraint = .Less
        } else {
            constraint = .Equal
        }
    }
}
