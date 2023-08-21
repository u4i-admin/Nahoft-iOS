//
//  LoginService.swift
//  Nahoft
//
//  Created by Sadra Sadri on 2.08.2023.
//

import Foundation

class LoginService {
    static let shared = LoginService()
    
    enum LoginError: Error {
        case passcodeNotSet
        case error
    }
    
    func login(code: String) throws -> LoginStatus {
        let passcode = try KeyChainStore.RetrieveItem(key: KeyChainStore.passcode)
        do {
            let destructionCode = try KeyChainStore.RetrieveItem(key: KeyChainStore.destructionCode)
            if destructionCode != nil && code == String(data: destructionCode!, encoding: .utf8) {
                return .SecondaryLogin
            }
        } catch {
            
        }
        
        guard passcode != nil else { throw LoginError.passcodeNotSet }
        if code == String(data: passcode!, encoding: .utf8) {
            // TODO: Add login flow
            return .LoggedIn
        }
        
        return .FailedLogin
    }
}
