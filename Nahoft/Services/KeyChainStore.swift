//
//  KeyChainStore.swift
//  Nahoft
//
//  Created by Sadra Sadri on 31.07.2023.
//

import Foundation
import Security

class KeyChainStore {
    static let privateKeyPreferencesKey = "NahoftPrivateKey"
    static let publicKeyPreferencesKey = "NahoftPublicKey"
    static let passcode = "Passcode"
    static let destructionCode = "Destruction"
    static let failedLoginAttempts = "FailedLoginAttempts"
    static let lastFailedLoginTime = "LastFailedLoginTime"
    static let service = "org.nahoft.keys".data(using: .utf8)!
//    static let keychainAccessGroupName = "xxxxxxxx.org.nahoft.nahoft"
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case noPassword
    }
    
    static func StoreItem(key: String, password: Data) throws {
        let addquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrService as String: service as AnyObject,
                                       kSecAttrAccount as String: key as AnyObject,
//                                       kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject,
                                       kSecValueData as String: password as AnyObject]
        
        let status = SecItemAdd(addquery as CFDictionary, nil)
        if status == errSecDuplicateItem {
            try UpdateItem(key: key, password: password)
            return
        }
        guard status == errSecSuccess else { throw KeychainError.unknown(status) }
    }
    
    static func UpdateItem(key: String, password: Data) throws {
        let updatequery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                          kSecAttrService as String: service as AnyObject,
                                          kSecAttrAccount as String: key as AnyObject]
        let attr: [String: Any] = [//kSecAttrAccount as String: key as AnyObject,
                                   kSecValueData as String: password as AnyObject]
        
        let status = SecItemUpdate(updatequery as CFDictionary, attr as CFDictionary)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unknown(status) }
    }
    
    static func RetrieveItem(key: String) throws -> Data? {
        let getquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrService as String: service as AnyObject,
                                       kSecAttrAccount as String: key as AnyObject,
                                       kSecReturnData as String: kCFBooleanTrue as Any,
//                                       kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject,
                                       kSecMatchLimit as String: kSecMatchLimitOne]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(getquery as CFDictionary, &result)
        guard status == errSecSuccess else { throw KeychainError.unknown(status) }
        if String(data: result as! Data, encoding: .utf8)?.count == 0 {
            do {
                try DeleteItem(key: key)
            } catch {}
        } //throw KeychainError.unknown(status) }
        return result as? Data
    }
    
    static func DeleteItem(key: String) throws {
        let getquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrService as String: service as AnyObject,
//                                       kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject,
                                       kSecAttrAccount as String: key as AnyObject]
        
        let status = SecItemDelete(getquery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unknown(status) }
    }
}
