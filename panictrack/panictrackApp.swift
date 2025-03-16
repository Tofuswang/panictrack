//
//  panictrackApp.swift
//  panictrack
//
//  Created by Tofus on 2025/3/16.
//

import SwiftUI

@main
struct panictrackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
