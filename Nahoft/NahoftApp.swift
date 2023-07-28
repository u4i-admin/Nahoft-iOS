//
//  NahoftApp.swift
//  Nahoft
//
//  Created by Work Account on 28.07.2023.
//

import SwiftUI

@main
struct NahoftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
