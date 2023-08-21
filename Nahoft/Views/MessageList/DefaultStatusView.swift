//
//  DefaultStatusView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 3.08.2023.
//

import SwiftUI

struct DefaultStatusView: View {
    @State private var passedFriend: Friend
    @State private var myPublicKey: String
    
    init(passedFriend: Friend) {
        self.passedFriend = passedFriend
        
        let keys = Encryption().ensureKeysExist()
        let publicKeyEncoded = Codex().encodeKey(key: keys.publicKey)
        self.myPublicKey = publicKeyEncoded
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: "lock.open.iphone")
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
            
            Text("No public key has been exchanged between you and \(passedFriend.name!) yet.")
                .padding()
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Please click the button bellow to submit your public key")
                .padding()
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Button {
                updateStatus()
            } label: {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 70))
            }
            .padding()
        }
    }
    
    func updateStatus() {
        let activityVC = UIActivityViewController(activityItems: [myPublicKey], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // otherwise iPad crashes
            let thisViewVC = UIHostingController(rootView: self)
            activityVC.popoverPresentationController?.sourceView = thisViewVC.view
        }
        
        UIApplication.shared.connectedScenes.flatMap {($0 as? UIWindowScene)?.windows ?? []}.first {$0.isKeyWindow}?.rootViewController?.present(activityVC, animated: true, completion: nil)
        
//        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        withAnimation {
            do {
                try PersistenceController.shared.updateFriendStatus(friend: passedFriend, status: .Invited)
            } catch {
                
            }
        }
    }
}

struct DefaultStatusView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultStatusView(passedFriend: Friend())
    }
}
