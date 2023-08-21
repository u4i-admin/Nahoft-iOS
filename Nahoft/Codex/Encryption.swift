//
//  Encryption.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import Foundation
import Sodium

class Encryption {
    let sodium = Sodium()
    
    private func generateKeypair() -> Keys {
        let seed = sodium.box.keyPair()!
        let keyPair = Keys(privateKey: seed.secretKey, publicKey: seed.publicKey)
        
        // Save the Keys
        do {
            try KeyChainStore.StoreItem(
                key: KeyChainStore.publicKeyPreferencesKey,
                password: Data(seed.publicKey)
            )
            
            try KeyChainStore.StoreItem(
                key: KeyChainStore.privateKeyPreferencesKey,
                password: Data(seed.secretKey)
            )
        } catch {
            print(error)
        }
        
        return keyPair
    }
    
    private func loadKeypair() -> Keys? {
        do {
            let privateKeyHex = try KeyChainStore.RetrieveItem(key: KeyChainStore.privateKeyPreferencesKey)
            let publicKeyHex = try KeyChainStore.RetrieveItem(key: KeyChainStore.publicKeyPreferencesKey)
            
            if (privateKeyHex == nil || publicKeyHex == nil) {
                return nil
            }
            
            let publicKey = Bytes(publicKeyHex!) //sodium.utils.hex2bin(String(decoding: publicKeyHex!, as: UTF8.self))
            let privateKey = Bytes(privateKeyHex!) //sodium.utils.hex2bin(String(decoding: privateKeyHex!, as: UTF8.self))
            return Keys(privateKey: privateKey, publicKey: publicKey)
        } catch {
            print(error)
        }
        return nil
    }

    func ensureKeysExist() -> Keys
    {
        return loadKeypair() ?? generateKeypair()
    }

    func encrypt(encodedPublicKey: Bytes, plaintext: String) -> Bytes
    {
        let privateKey = ensureKeysExist().privateKey
        let result: Bytes = sodium.box.seal(message: plaintext.bytes, recipientPublicKey: encodedPublicKey, senderSecretKey: privateKey)!
        return result

    }

    func decrypt(friendPublicKey: Bytes, ciphertext: Bytes) throws -> String
    {
    // TODO: Check for accessIsAllowed
//        if (!Persist.accessIsAllowed())
//        { return "" }
//        else
//        {
        let keypair = loadKeypair()
        let result = sodium.box.open(nonceAndAuthenticatedCipherText: ciphertext, senderPublicKey: friendPublicKey, recipientSecretKey: keypair!.privateKey)
        return String(decoding: result!, as: UTF8.self)
//        }
    }
}
