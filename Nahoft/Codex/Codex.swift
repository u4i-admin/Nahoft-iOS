//
//  Codex.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import Foundation
import Sodium

class Codex {
    func encodeKey(key: Bytes) -> String {
        return encode(firstByte: KeyOrMessage.Key.rawValue, data: key)
    }
    
    func encodeEncryptedMessage(message: Bytes) -> String
    {
        return encode(firstByte: KeyOrMessage.EncryptedMessage.rawValue, data: message)
    }

    func encode(firstByte: UInt8, data: Bytes) -> String
    {
        var typedData: Bytes = data
        typedData.insert(firstByte, at: 0)
        let script = WordScript()
        let result = script.encode(bytes: typedData)
        return result
    }

    func decode(ciphertext: String) -> DecodeResult?
    {
        let script = WordScript()
        var data = script.decode(ciphertext: ciphertext.trimmingCharacters(in: .whitespacesAndNewlines))
        if data.isEmpty { return nil }
        let type = data[0]
        data.removeFirst()

        if type == KeyOrMessage.Key.rawValue
        {
            return DecodeResult(KeyOrMessage.Key, data)
        } else if type == KeyOrMessage.EncryptedMessage.rawValue {
            return DecodeResult(KeyOrMessage.EncryptedMessage, data)
        }

        return nil
    }
}
