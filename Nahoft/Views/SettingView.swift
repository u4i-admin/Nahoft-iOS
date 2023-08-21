//
//  SettingView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 1.08.2023.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authentication: Authentication
    
    @State private var passcodeSet: Bool
    @State private var showPasscodeFields = false
    @State private var passcode = ""
    @State private var rePasscode = ""
    
    @State private var destructionCodeSet: Bool
    @State private var showDestructionCodeFields = false
    @State private var destructionCode = ""
    @State private var reDestructionCode = ""
    
    @State private var myPublicKey: String
    @State private var showAlert = false
    @State private var alertText = "Copied"
    
    @State private var showHelp = false
    
    init() {
        do {
            let pass = try KeyChainStore.RetrieveItem(key: KeyChainStore.passcode)
            if pass != nil {
                passcodeSet = true
            } else {
                passcodeSet = false
            }
        } catch {
            passcodeSet = false
        }
        
        do {
            let destruct = try KeyChainStore.RetrieveItem(key: KeyChainStore.destructionCode)
            if destruct != nil {
                destructionCodeSet = true
            } else {
                destructionCodeSet = false
            }
        } catch {
            destructionCodeSet = false
        }
        
        let keys = Encryption().ensureKeysExist()
        let publicKeyEncoded = Codex().encodeKey(key: keys.publicKey)
        self.myPublicKey = publicKeyEncoded
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Passcode") {
                        Toggle("Passcode", isOn: $passcodeSet)
                            .onChange(of: passcodeSet) { value in
                                withAnimation {
                                    showPasscodeFields = value
                                }
                                if (!value) {
                                    do {
                                        try KeyChainStore.DeleteItem(key: KeyChainStore.passcode)
                                        passcode = ""
                                        rePasscode = ""
                                        authentication.updateAuth(status: .NotRequired)
                                    } catch {
                                        passcodeSet = true
                                    }
                                }
                            }
                        
                        if showPasscodeFields {
                            SecureInputView("Enter your passcode", text: $passcode)
                                .keyboardType(.numberPad)
                                .onChange(of: passcode) { _ in
                                    passcode = String(passcode.prefix(6))
                                }
                            
                            SecureInputView("Re-Enter your passcode", text: $rePasscode)
                                .keyboardType(.numberPad)
                                .onChange(of: rePasscode) { _ in
                                    rePasscode = String(rePasscode.prefix(6))
                                }
                            
                            Button("Save", action: savePasscode)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .disabled(passcode.count != 6 || rePasscode.count != 6)
                        }
                    }
                    
                    Section("Destruction Code") {
                        Toggle("Destruction Code", isOn: $destructionCodeSet)
                            .disabled(!passcodeSet)
                            .onChange(of: destructionCodeSet) { value in
                                withAnimation {
                                    showDestructionCodeFields = value
                                }
                                if (!value) {
                                    do {
                                        try KeyChainStore.DeleteItem(key: KeyChainStore.destructionCode)
                                        destructionCode = ""
                                        reDestructionCode = ""
                                    } catch {
                                        destructionCodeSet = true
                                    }
                                }
                            }
                        
                        if showDestructionCodeFields {
                            SecureInputView("Enter your passcode", text: $destructionCode)
                                .keyboardType(.numberPad)
                                .onChange(of: destructionCode) { _ in
                                    destructionCode = String(destructionCode.prefix(6))
                                }
                            
                            SecureInputView("Re-Enter your passcode", text: $reDestructionCode)
                                .keyboardType(.numberPad)
                                .onChange(of: reDestructionCode) { _ in
                                    reDestructionCode = String(reDestructionCode.prefix(6))
                                }
                            
                            Button("Save", action: saveDestructionCode)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .disabled(destructionCode.count != 6 || reDestructionCode.count != 6)
                        }
                    }
                    
                    Section("Your Code") {
                        Text(myPublicKey)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                        
                        Button("Copy", action: copyPublicKey)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .alert(alertText, isPresented: $showAlert) {
                                Button("Ok", role: .cancel) {}
                            }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showHelp.toggle()
                    }, label: {
                        Label("Help", systemImage: "questionmark.circle")
                    })
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showHelp, content: {
                NavigationStack {
                    SliderView(slides: Slides.settingSlides)
                }
            })
        }
    }
    
    func savePasscode() {
        if passcode != rePasscode {
            alertText = "Passcodes are not same"
            showAlert = true
            return
        }
        
        if !isPasscodeNonSequential(passcode: passcode) || !isPasscodeNonRepeating(passcode: passcode) {
            return
        }
        
        do {
            try KeyChainStore.StoreItem(key: KeyChainStore.passcode, password: passcode.data(using: .utf8)!)
            alertText = "Your passcode has been saved"
            showAlert = true
            authentication.updateAuth(status: .LoggedIn)
        } catch {
            
        }
        withAnimation {
            showPasscodeFields = false
        }
    }
    
    func saveDestructionCode() {
        if destructionCode != reDestructionCode {
            alertText = "Destruction codes are not same"
            showAlert = true
            return
        }
        do {
            let pass = try KeyChainStore.RetrieveItem(key: KeyChainStore.passcode)
            let passString = String(data: pass!, encoding: .utf8)!
            
            if (passString == destructionCode) {
                alertText = "You cannot have a destruction code that is the same as your passcode"
                showAlert = true
                return
            }
            
            if !isPasscodeNonSequential(passcode: destructionCode) || !isPasscodeNonRepeating(passcode: destructionCode) {
                return
            }
            
            try KeyChainStore.StoreItem(key: KeyChainStore.destructionCode, password: destructionCode.data(using: .utf8)!)
            alertText = "Your destruction code has been saved"
            showAlert = true
        } catch {
            
        }
        
        withAnimation {
            showDestructionCodeFields = false
        }
    }
    
    func copyPublicKey() {
        UIPasteboard.general.string = myPublicKey
        alertText = "Copied"
        showAlert = true
    }
    
    func isPasscodeNonSequential(passcode: String) -> Bool {
        let digitArray = passcode.compactMap(\.wholeNumberValue)
        let max = digitArray.max()
        let min = digitArray.min()
        guard let max = max, let min = min else { return false }
        
        if (max - min) == (digitArray.count - 1) && Array(Set(digitArray)).count == digitArray.count {
            alertText = "Sequential passcodes are not allowed"
            showAlert = true
            return false
        }
        
        return true
    }
    
    func isPasscodeNonRepeating(passcode: String) -> Bool {
        let digitArray = passcode.compactMap(\.wholeNumberValue)
        
        for index in 1..<digitArray.count {
            let sec = digitArray[index]

            if (sec != digitArray[0]){
                return true
            }
        }

        alertText = "The passcode cannot be a repeated digit"
        showAlert = true
        return false
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(Authentication())
    }
}
