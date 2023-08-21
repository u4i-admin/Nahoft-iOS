//
//  DecodeResult.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import Foundation

class DecodeResult {
    let type: KeyOrMessage
    let payload: Array<UInt8>
    
    init(_ type: KeyOrMessage, _ payload: Array<UInt8>) {
        self.type = type
        self.payload = payload
    }
}
