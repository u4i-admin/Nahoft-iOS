//
//  InvitedStatusView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 3.08.2023.
//

import SwiftUI

struct InvitedStatusView: View {
    @State var passedFriend: Friend
    @State var friendsPublicKey = ""
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: "lock.iphone")
                        .font(.system(size: 120))
                        
                    Text("You")
                }
                .padding()
                
                VStack {
                    Image(systemName: "lock.open.iphone")
                        .font(.system(size: 120))
                    
                    Text(passedFriend.name!)
                }
                .padding()
            }
            .padding()
            
            Text("You have sent your public key to \(passedFriend.name!) and are now awaiting their public key in return.")
                .padding()
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Once you receive their public key, a secure connection will be stablished")
                .padding()
                .font(.title2)
                .multilineTextAlignment(.center)
            
            TextField("Your friend's public key", text: $friendsPublicKey, axis: .vertical)
                .multilineTextAlignment(.center)
                .padding()
            
            Button {
                importPublicKey()
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 70))
            }
            .padding()
        }
    }
    
    func importPublicKey() {
        withAnimation {
            do {
                let result = Codex().decode(ciphertext: friendsPublicKey)
                if (result?.type == .Key) {
                    let jsonData = try JsonService.toJson(data: result!.payload)
                    try PersistenceController.shared.updateFriendPublicKey(friend: passedFriend, publicKey: jsonData)
                    try PersistenceController.shared.updateFriendStatus(friend: passedFriend, status: .Approved)
                }
            } catch {
                
            }
        }
    }
}

struct InvitedStatusView_Previews: PreviewProvider {
    static var previews: some View {
        InvitedStatusView(passedFriend: Friend())
    }
}
