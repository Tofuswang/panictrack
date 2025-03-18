import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var panicStore: PanicStore
    
    init() {
        // Configure tab bar appearance
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
            ContentView()
                .tabItem {
                    Label(LocalizedStringKey("tab.panic"), systemImage: "hand.tap")
                }
            
            StatsPageView()
                .tabItem {
                    Label(LocalizedStringKey("tab.stats"), systemImage: "chart.bar")
                }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environmentObject(PanicStore())
}
