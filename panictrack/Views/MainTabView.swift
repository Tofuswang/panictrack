import SwiftUI

struct MainTabView: View {
    @StateObject private var panicStore = PanicStore()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        
        appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            ContentView(panicStore: panicStore)
                .tabItem {
                    Label("焦慮按鈕", systemImage: "hand.tap")
                }
            
            StatsPageView(panicStore: panicStore)
                .tabItem {
                    Label("統計數據", systemImage: "chart.bar")
                }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
