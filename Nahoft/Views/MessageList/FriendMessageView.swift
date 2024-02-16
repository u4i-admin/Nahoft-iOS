//
//  FriendMessageView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 3.08.2023.
//

import SwiftUI

struct FriendMessageView: View {
    @ObservedObject var passedMessage: Message
    
    var body: some View {
        HStack {
            Text(passedMessage.fromFriend?.name?.first?.uppercased() ?? "")
                .font(.title3)
                .padding(10)
                .frame(width: 50, height: 50)
                .background(.thinMaterial)
                .cornerRadius(20)
            
            VStack(alignment: .leading) {
                Text(decryptMessage(passedMessage.cipherText ?? ""))
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                
                Text(itemFormatter.string(from: passedMessage.date!))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    func decryptMessage(_ msg: String) -> String {
        do {
            let data = try JsonService.fromJson(str: passedMessage.fromFriend!.publicKeyEncoded!)
            let str = try JsonService.fromJson(str: msg)
            let decrypted = try Encryption().decrypt(friendPublicKey: data, ciphertext: str)
            return decrypted
        } catch {
            //print(error)
        }
        return "Decrypt failed"
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

//struct FriendMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendMessageView(passFriend: Friend())
//    }
//}
