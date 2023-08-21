//
//  FriendListView.swift
//  Share
//
//  Created by Work Account on 15.08.2023.
//

import SwiftUI

struct FriendListShareView: View {
    @State var searchText = ""
    @State var message: String
    @Environment(\.managedObjectContext) private var viewContext
    @State private var alertText = ""
    @State private var showAlert = false
    @State private var showSuccess = false
    @State private var friendList: [Friend]
    
    init(message: String) {
        self.message = message
        friendList = PersistenceController.shared.loadFriends(searchText: "")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(friendList, id:\.self) {friend in
                        DisplayFriendShareView(passedFriend: friend)
                            .onTapGesture {
                                importMessage(passedFriend: friend)
                            }
                    }
                }
                .searchable(text: $searchText, prompt: "Search...")
                .onChange(of: searchText) { newValue in
                    friendList = PersistenceController.shared.loadFriends(searchText: newValue)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("Nahoft")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                    }
//                            ToolbarItem {
//                                Button(action: {
//                                    showCreate.toggle()
//                                }, label: {
//                                    Label("Add Friend", systemImage: "plus")
//                                })
//                            }
                }
//                        .sheet(isPresented: $showCreate, content: {
//                            NavigationStack {
//                                AddFriendView()
//                            }
//                            .presentationDetents([.medium])
//                        })
            }
            .navigationTitle("Select Sender")
        }
        .alert(alertText, isPresented: $showAlert) {
            Button("Ok", role: .cancel) {}
        }
        .alert("Imported successfully", isPresented: $showSuccess) {
            Button("Done") { close() }
        }
    }
    
    func importMessage(passedFriend: Friend) {
        let result = Codex().decode(ciphertext: message)
        guard let result = result else {
            alertText = "Unable to decrypt the message"
            showAlert = true
            return
        }
        do {
            let data = try JsonService.fromJson(str: passedFriend.publicKeyEncoded!)
            _ = try Encryption().decrypt(friendPublicKey: data, ciphertext: result.payload)
            
            let jsonData = try JsonService.toJson(data: result.payload)
            try PersistenceController.shared.saveMessage(friend: passedFriend, messageText: jsonData, fromMe: false)
            showSuccess = true
        } catch {
            
        }
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
