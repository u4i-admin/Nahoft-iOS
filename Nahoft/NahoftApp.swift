//
//  NahoftApp.swift
//  Nahoft
//
//  Created by Sadra Sadri on 28.07.2023.
//

import SwiftUI
import BackgroundTasks
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct NahoftApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        checkForFirstTime()
    }
    
    @StateObject var authentication = Authentication()
    let persistenceController = PersistenceController.shared
    @State private var showSecureWindow: Bool = false
    @Environment(\.scenePhase) var scenePhase
    
//    init() {
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "org.nahoft.appLock", using: nil) { task in
//            TimeChangeService.handleAppRefresh(task: task as! BGAppRefreshTask)
//        }
//    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if authentication.loginStatus == .NotRequired || authentication.loginStatus == .LoggedIn || authentication.loginStatus == .SecondaryLogin {
                    FriendListView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(authentication)
                } else {
                    LoginView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(authentication)
                }
                if showSecureWindow {
                    Rectangle()
                        .scaledToFill()
                        .background(Color.white)
                        .foregroundColor(.white)
                    
                    Image("Nahoft")
                        .background(Color.white)
                }
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .background:
                showSecureWindow = true
                scheduleAppRefresh()
            case .inactive:
                showSecureWindow = true
            case .active:
                showSecureWindow = false
//                checkForFirstTime()
            @unknown default:
                break
            }
        }
        .backgroundTask(.appRefresh("org.nahoft.appLock")) {
            await authentication.logOut()
            print("Task ran")
        }
    }
    
    func scheduleAppRefresh() {
        if authentication.loginStatus == .LoggedIn {
        let request = BGAppRefreshTaskRequest(identifier: "org.nahoft.appLock")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background Task Scheduled!")
        } catch(let error) {
            print("Scheduling Error \(error.localizedDescription)")
            }
        }
    }
    
    func checkForFirstTime() {
        let encryptedMessage = UserDefaults.standard.string(forKey: "isFirstTime")
        if encryptedMessage == nil {
            LoginView().clearAllData(secondaryPass: false)
            authentication.updateAuth(status: .NotRequired)
            UserDefaults.standard.set("False", forKey: "isFirstTime")
        }
    }
}
