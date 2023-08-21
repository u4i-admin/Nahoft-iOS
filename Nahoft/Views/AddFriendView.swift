//
//  AddFriendView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 1.08.2023.
//

import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var name: String = ""
    
    @State var alertText = ""
    @State var showAlert = false
    var onSave: () -> ()
    
    var body: some View {
        Form {
            Section(header: Text("New Friend")) {
                TextField("Name", text: $name)
            }
            
            Section() {
                Button("Save", action: saveAction)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .alert(alertText, isPresented: $showAlert) {
                Button("Ok", role: .cancel) {}
            }
        }
    }
    
    func saveAction() {
        let friendList = PersistenceController.shared.loadFriends(searchText: "")
        let any = friendList.first(where: {$0.name == name})
        if any != nil {
            alertText = "There is a friend with the same name. Use another name."
            showAlert = true
            return
        }
        withAnimation {
            let newFriend = Friend(context: viewContext)
            newFriend.name = name
            newFriend.status = FriendStatus.Default.rawValue
            PersistenceController.shared.saveContext(viewContext)
            onSave()
            dismiss()
        }
    }
}

struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView(onSave: {})
    }
}
