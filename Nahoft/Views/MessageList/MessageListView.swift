//
//  MessageListView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 1.08.2023.
//

import SwiftUI
import PhotosUI

struct MessageListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.layoutDirection) var direction
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var passedFriend: Friend
    @State var encodedMessage = ""
    @State var decodedMessage = ""
    @State var showImportText = false
    @State var showFriendDetail = false
    @State var showHelp = false
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var imageData: UIImage? = nil
    
    let importMessageTip = ImportMessageTip()
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                let messages = passedFriend.toMessage?.sortedArray(using: buildSortDescriptors()) as! [Message]
                ScrollView {
                    if passedFriend.status == FriendStatus.Default.rawValue {
                        DefaultStatusView(passedFriend: passedFriend)
                    } else if passedFriend.status == FriendStatus.Invited.rawValue {
                        InvitedStatusView(passedFriend: passedFriend)
                    } else {
                        VStack {
                            ForEach(messages, id:\.id) { message in
                                if message.fromMe {
                                    MyMessageView(passedMessage: message)
                                        .id(message.id)
                                } else {
                                    FriendMessageView(passedMessage: message)
                                        .id(message.id)
                                }
                            }
                            
                            Spacer().id("last")
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                .onAppear {
                    value.scrollTo("last")
                }
                .onChange(of: messages) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        value.scrollTo("last")
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading:
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: direction == .leftToRight ? "chevron.left" : "chevron.right")
                        }
                    
                        Button {
                            showFriendDetail = true
                        } label: {
                            HStack {
                                ZStack(alignment: .bottomTrailing) {
                                    Text(passedFriend.name?.first?.uppercased() ?? "")
                                        .font(.title)
                                        .padding(8)
                                        .frame(width: 40, height: 40)
                                        .background(.thinMaterial)
                                        .cornerRadius(15)
                                    
                                    Circle()
                                        .foregroundColor(FriendStatus(rawValue: passedFriend.status)?.color ?? Color("StatusIconDefault"))
                                        .frame(width: 10, height: 10)
                                }
                                
                                Text(passedFriend.name ?? "")
                            }
                        }
                    }
                )
                .sheet(isPresented: $showImportText, content: {
                    NavigationStack {
                        ImportMessageView(passedFriend: passedFriend)
                    }
                    .presentationDetents([.medium])
                })
                .sheet(isPresented: $showFriendDetail, content: {
                    NavigationStack {
                        FriendDetailView(passedFriend: passedFriend)
                    }
                })
                .sheet(isPresented: $showHelp, content: {
                    NavigationStack {
                        SliderView(slides: Slides.messageListSlides)
                    }
                })
                .toolbar {
                    ToolbarItem {
                        Button {
                            showHelp.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                    }
                    
                    if passedFriend.status == FriendStatus.Approved.rawValue || passedFriend.status == FriendStatus.Verified.rawValue {
//                        ToolbarItem {
//                            PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images, photoLibrary: .shared()) {
//                                ZStack {
//                                    Image(systemName: "photo")
//                                    
//                                    VStack {
//                                        Spacer()
//                                        
//                                        HStack {
//                                            Spacer()
//                                            
//                                            Image(systemName: "arrow.down.circle.fill")
//                                                .background(Color(UIColor.systemBackground))
//                                                .font(.system(size: 10))
//                                        }
//                                    }
//                                }
//                            }
//                            .onChange(of: selectedItems) { newValue in
//                                for item in newValue {
//                                    Task {
//                                        if let data = try? await item.loadTransferable(type: Data.self) {
//                                            imageData = UIImage(data: data)
//                                            let decoder = Decoder()
//                                            let _ = decoder.decode(image: imageData!)
//                                        }
//                                    }
//                                }
//                            }
//                        }
                        
                        ToolbarItem {
                            Button {
                                showImportText.toggle()
                            } label: {
                                ZStack {
                                    Image(systemName: "text.bubble")
                                    
                                    VStack {
                                        Spacer()
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Image(systemName: "arrow.down.circle.fill")
                                                .background(Color(UIColor.systemBackground))
                                                .font(.system(size: 10))
                                        }
                                    }
                                }
                            }
                            .popoverTip(importMessageTip)
                        }
                    }
                }
            }
            
            if passedFriend.status == FriendStatus.Approved.rawValue || passedFriend.status == FriendStatus.Verified.rawValue {
                SendMessageView(passedFriend: passedFriend)
            }
        }
    }
    
    func buildSortDescriptors() -> [NSSortDescriptor] {
        [NSSortDescriptor(key: "date", ascending: true)]
    }
}

//struct MessageListView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageListView(passedFriend: Friend())
//    }
//}
