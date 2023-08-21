//
//  LoginView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 2.08.2023.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authentication: Authentication
    @Environment(\.managedObjectContext) private var viewContext
    @State private var passcode = ""
    @State private var alertText = ""
    @State private var showAlert = false
    
    @State private var failedLoginAttempts = 0
    @State private var lastFailedLoginTime: Date? = nil
    
    var body: some View {
        ZStack {
            Color("BlueCrayola")
                .ignoresSafeArea()
            
            VStack {
                Image("Nahoft")
                    .resizable()
                    .frame(width: 200, height: 200)
                
                SecureInputView("Enter Your Passcode", text: $passcode)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.bottom, 30)
                    .keyboardType(.numberPad)
                    .onChange(of: passcode) { _ in
                        passcode = String(passcode.prefix(6))
                    }
                
                Button {
                    login()
                } label: {
                    Text("Login")
                        .padding(.horizontal, 10)
                    
                    Image(systemName: authentication.biometricType() == .face ? "faceid" : "touchid")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(15)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 5)
                .disabled(passcode.count != 6)
                .alert(alertText, isPresented: $showAlert) {
                    Button("Ok", role: .cancel) {}
                }
            }
        }
    }
    
    func login() {
        do {
            let failed = try KeyChainStore.RetrieveItem(key: KeyChainStore.failedLoginAttempts)
            let lastTime = try KeyChainStore.RetrieveItem(key: KeyChainStore.lastFailedLoginTime)
            failedLoginAttempts = Int(String(data: failed!, encoding: .utf8)!) ?? 0
            
            if let lastTime = lastTime {
                let retrievedTimestamp = lastTime.withUnsafeBytes { $0.load(as: Double.self) }
                let retrievedDate = Date(timeIntervalSinceReferenceDate: retrievedTimestamp)
                
                lastFailedLoginTime = retrievedDate
            }
        } catch {
            failedLoginAttempts = 0
        }
        
        authentication.requestBiometricUnlock {
            (result: Result<LoginStatus, Authentication.AuthenticationError>) in
            switch result {
            case .success(_):
                if !loginAllowed() { return }
                do {
                    let result = try LoginService.shared.login(code: passcode)
                    if result == .LoggedIn {
                        try KeyChainStore.StoreItem(key: KeyChainStore.failedLoginAttempts, password: "0".data(using: .utf8)!)
                        
                        withAnimation {
                            authentication.updateAuth(status: result)
                        }
                    } else if result == .SecondaryLogin {
                        clearAllData(secondaryPass: true)
                        
                        withAnimation {
                            authentication.updateAuth(status: result)
                        }
                    } else {
                        failedLoginAttempts += 1
                        try KeyChainStore.StoreItem(key: KeyChainStore.failedLoginAttempts, password: String(failedLoginAttempts).data(using: .utf8)!)
                        
                        let timestamp = Date.now.timeIntervalSinceReferenceDate
                        let data = withUnsafeBytes(of: timestamp) { Data($0) }
                        
                        try KeyChainStore.StoreItem(key: KeyChainStore.lastFailedLoginTime, password: data)
                        
                        if !showAlert {
                            showLockoutMessage()
                        }
                    }
                } catch LoginService.LoginError.passcodeNotSet {
                    alertText = "Passcode not set"
                    showAlert = true
                } catch {
                    alertText = "Something is wrong"
                    showAlert = true
                }
            case .failure(let error):
                alertText = error.localizedDescription
                showAlert = true
                return
            }
        }
    }
    
    func getLockoutMinutes() -> Int {
        if failedLoginAttempts >= 9 {
            clearAllData(secondaryPass: false)
            withAnimation {
                authentication.updateAuth(status: .NotRequired)
            }
            return 1000
        } else if failedLoginAttempts == 8 {
            return 15
        } else if failedLoginAttempts == 7 {
            return 5
        } else if failedLoginAttempts == 6 {
            return 1
        } else {
            return 0
        }
    }
    
    func showLockoutMessage() {
        if failedLoginAttempts >= 9 {
            alertText = "The passcode entered is incorrect. This account has been deleted."
            clearAllData(secondaryPass: false)
            withAnimation {
                authentication.updateAuth(status: .NotRequired)
            }
        } else if failedLoginAttempts == 8 {
            alertText = "The passcode entered is incorrect. You can try logging in again in 15 minutes."
        } else if failedLoginAttempts == 7 {
            alertText = "The passcode entered is incorrect. You can try logging in again in 5 minutes."
        } else if failedLoginAttempts == 6 {
            alertText = "The passcode entered is incorrect. You can try logging in again in 60 seconds."
        } else {
            alertText = "The passcode entered is incorrect. Please try again."
        }
        showAlert = true
    }
    
    func clearAllData(secondaryPass: Bool) {
        do {
            try PersistenceController.shared.clearAll()
            
            try KeyChainStore.DeleteItem(key: KeyChainStore.destructionCode)
            try KeyChainStore.DeleteItem(key: KeyChainStore.passcode)
            try KeyChainStore.DeleteItem(key: KeyChainStore.privateKeyPreferencesKey)
            try KeyChainStore.DeleteItem(key: KeyChainStore.publicKeyPreferencesKey)
            try KeyChainStore.StoreItem(key: KeyChainStore.failedLoginAttempts, password: "0".data(using: .utf8)!)
            
            if secondaryPass {
                try KeyChainStore.StoreItem(key: KeyChainStore.passcode, password: passcode.data(using: .utf8)!)
            }
        } catch {
            
        }
    }
    
    func loginAllowed() -> Bool {
        let minutesToWait = getLockoutMinutes()
        
        if minutesToWait == 0 {
            return true
        } else if minutesToWait >= 100 {
            //This should never happen all data should have already been deleted when the login failed the final time.
            //Delete everything like you would if user had entered a secondary passcode.
            alertText = "The passcode entered is incorrect. This account has been deleted."
            clearAllData(secondaryPass: false)
            withAnimation {
                authentication.updateAuth(status: .NotRequired)
            }

            return false
        }
        
        if let lastFailedLoginTime = lastFailedLoginTime {
            let unlockTime = lastFailedLoginTime.addingTimeInterval(TimeInterval(minutesToWait * 60))
            
            if (unlockTime < Date.now) {
                return true
            } else {
                let remaining = Int(unlockTime.timeIntervalSince(Date.now))
                let min = remaining / 60
                let sec = remaining % 60
                
                alertText = "Please wait, \(min) minutes \(sec) seconds before attempting to login again"
                showAlert = true

                return false
            }
        } else {
            print("ERROR: Last failed login timestamp is null, but user has more than 5 failed login attempts.")
            
            return false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(Authentication())
    }
}
