//
//  SwiftUIView.swift
//  Share
//
//  Created by Sadra Sadri on 4.08.2023.
//

import SwiftUI

struct SwiftUIView: View {
    @StateObject var authentication = Authentication()
    @State public var incoming_text: String
    
    var body: some View {
        if authentication.loginStatus == .NotRequired || authentication.loginStatus == .LoggedIn || authentication.loginStatus == .SecondaryLogin {
            FriendListShareView(message: incoming_text)
        } else {
            LoginView()
                .environmentObject(authentication)
        }
    }
}
