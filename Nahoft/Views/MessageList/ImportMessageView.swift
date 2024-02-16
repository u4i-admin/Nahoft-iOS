//
//  ImportMessageView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 3.08.2023.
//

import SwiftUI

struct ImportMessageView: View {
    @Environment(\.dismiss) var dismiss
    @State var passedFriend: Friend
    @State var msg: String = ""
    
    @State private var alertText = ""
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Import Message")) {
                TextField("Message from your friend", text: $msg, axis: .vertical)
            }
            
            Section() {
                Button("Import", action: importAction)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .alert(alertText, isPresented: $showAlert) {
            Button("Ok", role: .cancel) {}
        }
    }
    
    func importAction() {
        let result = Codex().decode(ciphertext: msg)
        guard let result = result else {
            alertText = "Unable to decrypt the message"
            showAlert = true
            return
        }
        if result.type == .Key {
            alertText = "This message contains a public key"
            showAlert = true
            return
        }
        do {
            let data = try JsonService.fromJson(str: passedFriend.publicKeyEncoded!)
            _ = try Encryption().decrypt(friendPublicKey: data, ciphertext: result.payload)
            
            let jsonData = try JsonService.toJson(data: result.payload)
            try PersistenceController.shared.saveMessage(friend: passedFriend, messageText: jsonData, fromMe: false)
        } catch {
            
        }
        msg = ""
        dismiss()
    }
}

struct ImportMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ImportMessageView(passedFriend: Friend())
    }
}
