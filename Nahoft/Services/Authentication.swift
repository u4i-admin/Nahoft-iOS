//
//  Authentication.swift
//  Nahoft
//
//  Created by Sadra Sadri on 2.08.2023.
//

import SwiftUI
import LocalAuthentication

class Authentication: ObservableObject {
    @Published var loginStatus = LoginStatus.NotRequired
    @Published var isAuthorized = false
    
    enum BiometricType {
        case none
        case face
        case touch
    }
    
    enum AuthenticationError: Error, LocalizedError, Identifiable {
        case invalidCredentials
        case deniedAccess
        case noFaceIdEnrolled
        case noFingerprintEnrolled
        case biometricError
        
        var id: String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return NSLocalizedString("Your passcode is incorrect", comment: "")
            case .deniedAccess:
                return NSLocalizedString("You have denied access. Please go to the settings app and locate Nahoft and turn Face ID on.", comment: "")
            case .noFaceIdEnrolled:
                return NSLocalizedString("You have not registered any Face IDs yet.", comment: "")
            case .noFingerprintEnrolled:
                return NSLocalizedString("You have not registered any fingerprint yet.", comment: "")
            case .biometricError:
                return NSLocalizedString("Your Face ID or fingerprint were not recognized", comment: "")
            }
        }
    }
    
    init() {
        do {
            let passcode = try KeyChainStore.RetrieveItem(key: KeyChainStore.passcode)
            if passcode != nil {
                self.loginStatus = .LoggedOut
            }
        } catch {
            
        }
    }
    
    func updateAuth(status: LoginStatus) {
        withAnimation {
            loginStatus = status
        }
    }
    
    func logOut() async {
        loginStatus = .LoggedOut
    }
    
    func biometricType() -> BiometricType {
        let authContext = LAContext()
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touch
        case .faceID:
            return .face
        @unknown default:
            return .none
        }
    }
    
    func requestBiometricUnlock(completion: @escaping (Result<LoginStatus, AuthenticationError>) -> Void) {
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            switch error.code {
            case -6:
                completion(.failure(.deniedAccess))
            case -7:
                if context.biometryType == .faceID {
                    completion(.failure(.noFaceIdEnrolled))
                } else {
                    completion(.failure(.noFingerprintEnrolled))
                }
            default:
                completion(.failure(.biometricError))
            }
            return
        }
        
        if canEvaluate {
            if context.biometryType != .none {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Need to access credentials.") {
                    success, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            completion(.failure(.biometricError))
                        } else {
                            completion(.success(.LoggedIn))
                        }
                    }
                }
            }
        }
    }
}
