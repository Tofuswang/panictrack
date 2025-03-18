//
//  panictrackApp.swift
//  panictrack
//
//  Created by Tofus on 2025/3/16.
//

import SwiftUI

@main
struct panictrackApp: App {
    @StateObject private var panicStore = PanicStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(panicStore)
        }
    }
}
