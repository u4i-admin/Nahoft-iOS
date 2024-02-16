//
//  SendMessageView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 3.08.2023.
//

import SwiftUI
import PhotosUI

struct SendMessageView: View {
    @State var message = ""
    @State var passedFriend: Friend
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var imageData: UIImage? = nil
    
    @State private var showImportConfirmation = false
    
    var body: some View {
        HStack(spacing: 15) {
//            PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images, photoLibrary: .shared()) {
//                Image(systemName: "photo.on.rectangle")
//                    .font(.system(size: 24))
//            }
//            .onChange(of: selectedItems) { newValue in
//                for item in newValue {
//                    Task {
//                        if let data = try? await item.loadTransferable(type: Data.self) {
//                            imageData = UIImage(data: data)
//                            if let imageData {
//                                sendAsImage(cover: imageData)
//                            }
//                        }
//                    }
//                }
//            }
//            Button {
//                sendAsImage()
//            } label: {
//                Image(systemName: "photo.on.rectangle")
//                    .font(.system(size: 24))
//                    .foregroundColor(Color(.darkGray))
//            }
            
            TextField("Type Your Message", text: $message, axis: .vertical)
            
            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 24))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .confirmationDialog("Import message?", isPresented: $showImportConfirmation) {
            Button("Yes") { importMessage() }
            Button("No") { encodeMessage() }
        } message: {
            Text("The text you are attempting to send has already been encrypted. Would you like to decrypt it instead of sending it?")
        }
    }
    
    func sendMessage() {
        let decodedResult = Codex().decode(ciphertext: message)
        if decodedResult != nil {
            showImportConfirmation = true
        } else {
            encodeMessage()
        }
    }
    
    func importMessage() {
        let result = Codex().decode(ciphertext: message)
        
        do {
            let data = try JsonService.fromJson(str: passedFriend.publicKeyEncoded!)
            _ = try Encryption().decrypt(friendPublicKey: data, ciphertext: result!.payload)
            
            let jsonData = try JsonService.toJson(data: result!.payload)
            try PersistenceController.shared.saveMessage(friend: passedFriend, messageText: jsonData, fromMe: false)
        } catch {
            
        }
        message = ""
    }
    
    func encodeMessage() {
        do {
            let data = try JsonService.fromJson(str: passedFriend.publicKeyEncoded!)
            let encrypted = Encryption().encrypt(encodedPublicKey: data, plaintext: message)
            let result = Codex().encodeEncryptedMessage(message: encrypted)
            let json = try JsonService.toJson(data: encrypted)
            try PersistenceController.shared.saveMessage(friend: passedFriend, messageText: json, fromMe: true)
            let activityVC = UIActivityViewController(activityItems: [result], applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // otherwise iPad crashes
                let thisViewVC = UIHostingController(rootView: self)
                activityVC.popoverPresentationController?.sourceView = thisViewVC.view
            }
            
            UIApplication.shared.connectedScenes.flatMap {($0 as? UIWindowScene)?.windows ?? []}.first {$0.isKeyWindow}?.rootViewController?.present(activityVC, animated: true, completion: nil)
            
            message = ""
        } catch {
            
        }
    }
    
    func sendAsImage(cover: UIImage) {
        do {
            let data = try JsonService.fromJson(str: passedFriend.publicKeyEncoded!)
            let encrypted = Encryption().encrypt(encodedPublicKey: data, plaintext: message)
            let result = Encoder().encode(encrypted: encrypted, cover: cover, saveToGallery: true)
            let json = try JsonService.toJson(data: encrypted)
            try PersistenceController.shared.saveMessage(friend: passedFriend, messageText: json, fromMe: true)
            
            guard let result = result else { return }
            let activityVC = UIActivityViewController(activityItems: [result], applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // otherwise iPad crashes
                let thisViewVC = UIHostingController(rootView: self)
                activityVC.popoverPresentationController?.sourceView = thisViewVC.view
            }
            
            UIApplication.shared.connectedScenes.flatMap {($0 as? UIWindowScene)?.windows ?? []}.first {$0.isKeyWindow}?.rootViewController?.present(activityVC, animated: true, completion: nil)
            
            message = ""
        } catch {
            
        }
    }
}

//struct SendMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        SendMessageView(passedFriend: Friend())
//    }
//}
