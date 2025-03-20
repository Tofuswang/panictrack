//
//  panictrackApp.swift
//  panictrack
//
//  Created by Tofus on 2025/3/16.
//

import SwiftUI
import UIKit

// Add this class to restrict orientation to portrait only
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Return only portrait orientation
        return .portrait
    }
}

@main
struct panictrackApp: App {
    // Register the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var panicStore = PanicStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(panicStore)
                .onAppear {
                    checkAndTriggerHaptic()
                }
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    private func checkAndTriggerHaptic() {
        let defaults = UserDefaults(suiteName: "group.com.tofus.panictrack")
        if let shouldTrigger = defaults?.bool(forKey: "triggerHaptic"), shouldTrigger,
           let timestamp = defaults?.double(forKey: "hapticTimestamp") {
            
            // 只處理最近 5 秒內的請求
            let now = Date().timeIntervalSince1970
            if (now - timestamp) < 5.0 {
                // 觸發震動
                triggerHapticFeedback()
                
                // 重置標記
                defaults?.set(false, forKey: "triggerHaptic")
            }
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        
        // 額外的震動效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactGenerator.prepare()
            impactGenerator.impactOccurred()
        }
    }
    
    private func handleURL(_ url: URL) {
        guard url.scheme == "panictrack" else { return }
        
        if url.host == "recordPanic" {
            // Widget 已經記錄了焦慮發作，所以這裡只需要觸發震動
            checkAndTriggerHaptic()
        }
    }
}
