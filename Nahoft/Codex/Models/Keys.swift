//
//  Keys.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import Foundation
import Sodium

class Keys {
    let privateKey: Bytes
    let publicKey: Bytes
    
    init(privateKey: Bytes, publicKey: Bytes) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
