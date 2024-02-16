//
//  MyMessageView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 3.08.2023.
//

import SwiftUI

struct MyMessageView: View {
    @ObservedObject var passedMessage: Message
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(decryptMessage(passedMessage.cipherText ?? ""))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                
                Text(itemFormatter.string(from: passedMessage.date!))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("Me")
                .font(.title3)
                .padding(10)
                .frame(width: 50, height: 50)
                .background(.thinMaterial)
                .cornerRadius(20)
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

//struct MyMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyMessageView()
//    }
//}
