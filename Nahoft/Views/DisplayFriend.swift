//
//  DisplayFriend.swift
//  Nahoft
//
//  Created by Sadra Sadri on 1.08.2023.
//

import SwiftUI

struct DisplayFriend: View {
    @ObservedObject var passedFriend: Friend
    
    var body: some View {
        HStack {
            Text(passedFriend.name?.first?.uppercased() ?? "")
                .font(.title)
                .padding(10)
                .frame(width: 50, height: 50)
                .background(.thinMaterial)
                .cornerRadius(20)
            
            Text(passedFriend.name ?? "")
            
            Spacer()
            
            Text(FriendStatus(rawValue: passedFriend.status)?.value ?? "")
                .font(.caption)
            
            Circle()
                .foregroundColor(FriendStatus(rawValue: passedFriend.status)?.color ?? Color("StatusIconDefault"))
                .frame(width: 15, height: 15)
        }
    }
}

struct DisplayFriend_Previews: PreviewProvider {
    static var previews: some View {
        DisplayFriend(passedFriend: Friend())
    }
}
