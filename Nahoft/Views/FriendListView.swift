//
//  ContentView.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import SwiftUI
import CoreData

struct FriendListView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var authentication: Authentication
    @Environment(\.managedObjectContext) private var viewContext
    @State var searchText = ""
    @State var editMode: EditMode = .inactive
    @State private var showCreate = false
    @State private var showSetting = false
    @State private var isFirstTime = false
    @State private var showHelp = false
    @State private var showAbout = false
    @State private var friendList: [Friend] = []
    
    init() {
        friendList = PersistenceController.shared.loadFriends(searchText: "")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(friendList, id:\.self) {friend in
                        NavigationLink(destination: MessageListView(passedFriend: friend)) {
                            DisplayFriend(passedFriend: friend)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewContext.delete(friendList[index])
                        }
                        PersistenceController.shared.saveContext(viewContext)
                    }
                }
                .environment(\.editMode, $editMode)
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
                            .onTapGesture {
                                showAbout.toggle()
                            }
                    }
                    
//                            ToolbarItem(placement: .navigationBarTrailing) {
//                                Button(action: {
//                                    withAnimation {
//                                        editMode = editMode == .inactive ? .active : .inactive
//                                    }
//                                }, label: {
//                                    Label("Edit Friends", systemImage: "square.and.pencil")
//                                })
//                            }
                    
                    ToolbarItem {
                        Button(action: {
                            showCreate.toggle()
                        }, label: {
                            Label("Add Friend", systemImage: "plus")
                        })
                    }
                    
                    ToolbarItem {
                        Button(action: {
                            showHelp.toggle()
                        }, label: {
                            Label("Help", systemImage: "questionmark.circle")
                        })
                    }
                    
                    ToolbarItem {
                        Button(action: {
                            showSetting.toggle()
                        }, label: {
                            Label("Setting", systemImage: "gearshape")
                        })
                    }
                }
                .sheet(isPresented: $showCreate, content: {
                    NavigationStack {
                        AddFriendView(onSave: {
                            self.friendList = PersistenceController.shared.loadFriends(searchText: searchText)
                        })
                    }
                    .presentationDetents([.medium])
                })
                .sheet(isPresented: $showSetting, content: {
                    NavigationStack {
                        SettingView()
                            .environmentObject(authentication)
                    }
                })
                .sheet(isPresented: $isFirstTime, content: {
                    NavigationStack {
                        SliderView(slides: Slides.introSlides)
                    }
                })
                .sheet(isPresented: $showHelp, content: {
                    NavigationStack {
                        SliderView(slides: Slides.friendListSlides)
                    }
                })
                .sheet(isPresented: $showAbout, content: {
                    NavigationStack {
                        SliderView(slides: Slides.aboutSlides)
                    }
                })
                
                Spacer()
                
                if authentication.loginStatus == .LoggedIn || authentication.loginStatus == .SecondaryLogin {
                    Button("Logout", action: logout)
                }
            }
            .navigationTitle("Friend List")
        }
        .onAppear() {
            do {
                let _ = try KeyChainStore.RetrieveItem(key: KeyChainStore.privateKeyPreferencesKey)
            } catch {
                do {
                    let _ = try KeyChainStore.RetrieveItem(key: KeyChainStore.passcode)
                } catch {
                    isFirstTime = true
                }
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                PersistenceController.shared.reloadAllData()
                self.friendList = PersistenceController.shared.loadFriends(searchText: searchText)
            case .background:
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
    
    func logout() {
        authentication.updateAuth(status: .LoggedOut)
    }
    
//    func buildPredicate() -> NSPredicate {
//        searchText == "" ? NSPredicate(value: true) : NSPredicate(format: "name CONTAINS[cd] %@", searchText)
//    }
//
//    func buildSortDescriptors() -> [NSSortDescriptor] {
//        [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(Authentication())
    }
}
