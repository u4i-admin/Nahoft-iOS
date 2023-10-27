//
//  Solver.swift
//  Nahoft
//
//  Created by Sadra Sadri on 9.08.2023.
//

import Foundation
import UIKit

class Solver {
    var coverImageBitmap: UIImage
    var messageARules: [Rule]
    
    init(coverImageBitmap: UIImage, messageARules: [Rule]) {
        self.coverImageBitmap = coverImageBitmap
        self.messageARules = messageARules
    }
    
    func constrain() -> Bool {
        for rule in messageARules {
            let success = rule.constrain()
            if (!success) {
                return false
            }
        }
        
        return true
    }
}
