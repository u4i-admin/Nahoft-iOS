//
//  FriendDetailView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 14.08.2023.
//

import SwiftUI

struct FriendDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var passedFriend: Friend
    
    @State var friendsPublicKey: String = ""
    @State var friendsName: String = ""
    @State var myPublicKey: String = ""
    @State var alertText: String = ""
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack {
            Form {
                Section("Name") {
                    TextField("Nickname", text: $friendsName)
                    
                    Button("Save", action: saveName)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section("Public Key") {
                    Label {
                        Text(myPublicKey)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } icon: {
                        Text("Me")
                    }
                    
                    Label {
                        Text(friendsPublicKey)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } icon: {
                        Text((friendsName.first?.uppercased()) ?? "")
                    }
                        
                    Button {
                        reject()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.shield.fill")
                                .padding(.horizontal)
                            
                            Text("Reject")
                        }
                    }
                    .foregroundColor(passedFriend.status != FriendStatus.Approved.rawValue && passedFriend.status != FriendStatus.Verified.rawValue ? .gray : .red)
                    .disabled(passedFriend.status != FriendStatus.Approved.rawValue && passedFriend.status != FriendStatus.Verified.rawValue)
                    
                    Button {
                        approve()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .padding(.horizontal)
                            
                            Text("Approve")
                        }
                    }
                    .disabled(passedFriend.status != FriendStatus.Approved.rawValue)
                }
            }
        }
        .alert(alertText, isPresented: $showAlert) {
            Button("Ok", role: .cancel) {}
        }
        .onAppear() {
            friendsName = passedFriend.name!
            let keys = Encryption().ensureKeysExist()
            let publicKeyEncoded = Codex().encodeKey(key: keys.publicKey)
            self.myPublicKey = publicKeyEncoded
            
            do {
                guard let pk = passedFriend.publicKeyEncoded else {
                    return
                }
                let data = try JsonService.fromJson(str: pk)
                friendsPublicKey = Codex().encodeKey(key: data)
            } catch {
                
            }
        }
    }
    
    func saveName() {
        let friendList = PersistenceController.shared.loadFriends(searchText: "")
        let any = friendList.first(where: {$0.name == friendsName})
        if any != nil {
            alertText = "There is a friend with the same name. Use another name."
            showAlert = true
            return
        }
        passedFriend.name = friendsName
        PersistenceController.shared.saveContext(viewContext)
        alertText = "Changed"
        showAlert = true
    }
    
    func reject() {
        passedFriend.status = FriendStatus.Default.rawValue
        passedFriend.publicKeyEncoded = nil
        PersistenceController.shared.saveContext(viewContext)
        withAnimation {
            dismiss()
        }
    }
    
    func approve() {
        passedFriend.status = FriendStatus.Verified.rawValue
        PersistenceController.shared.saveContext(viewContext)
        withAnimation {
            dismiss()
        }
    }
}

//struct FriendDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendDetailView(passedFriend: Friend())
//    }
//}
