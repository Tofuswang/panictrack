import SwiftUI

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @EnvironmentObject var panicStore: PanicStore
    @State private var showingHelp = false
    @State private var showEmoji = false
    @State private var emojiPosition: CGPoint = .zero
    // Use a state property for vibration setting with a default value
    @State private var isVibrationEnabled = true
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        // Title section with black background
                        ZStack {
                            Color.black
                                .frame(height: 80) // 減少標題高度
                                .edgesIgnoringSafeArea(.top)
                            
                            HStack {
                                Text(LocalizedStringKey("content.title"))
                                    .font(.system(size: 33, weight: .bold)) // 減小字體
                                    .foregroundColor(.primary)
                                    .padding(.leading)
                                
                                Spacer()
                                
                                Button {
                                    showingHelp = true
                                } label: {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 22))
                                        .foregroundColor(.primary)
                                }
                                .padding(.trailing)
                            }
                            .padding(.top, 40) // 減少頂部邊距
                        }
                        
                        // Main content area with stats and panic button using GeometryReader for relative positioning
                        GeometryReader { mainGeometry in
                            VStack {
                                // Stats view at the top - takes about 20% of the screen height
                                StatsView(
                                    todayCount: panicStore.entriesForDate(Date()).count,
                                    weekCount: panicStore.entriesForLastNDays(7).count
                                )
                                .frame(height: mainGeometry.size.height * 0.2)
                                .padding(.horizontal, 12)
                                .padding(.top, 0)
                                
                                // 使用固定高度的 Spacer 來控制間距
                                Spacer().frame(height: mainGeometry.size.height * 0.2)
                                
                                // Large rectangular panic button - takes about 1/3 of the screen height
                                PanicButton {
                                    panicStore.addEntry()
                                    
                                    // Show emoji on every tap - positioned higher above the button
                                    emojiPosition = CGPoint(
                                        x: mainGeometry.frame(in: .global).midX,
                                        y: mainGeometry.frame(in: .global).midY - mainGeometry.size.height * 0.15
                                    )
                                    showEmoji = true
                                    // Haptic feedback with maximum intensity
                                    let todayCount = panicStore.entriesForDate(Date()).count
                                    
                                    if isVibrationEnabled {
                                        // Use notification feedback for strongest vibration
                                        let notificationGenerator = UINotificationFeedbackGenerator()
                                        notificationGenerator.notificationOccurred(.error) // Strongest system vibration
                                        
                                        // Add heavy impact vibrations
                                        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
                                        heavyGenerator.impactOccurred(intensity: 1.0)
                                        
                                        // For milestone taps, add extra intense vibrations
                                        if todayCount % 10 == 0 && todayCount > 0 {
                                            // Add multiple vibrations in sequence for maximum effect
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                heavyGenerator.impactOccurred(intensity: 1.0)
                                                notificationGenerator.notificationOccurred(.error)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                heavyGenerator.impactOccurred(intensity: 1.0)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                notificationGenerator.notificationOccurred(.error)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: min(mainGeometry.size.width * 0.95, 400)) // 限制最大寬度
                                .frame(height: min(mainGeometry.size.height * 0.33, 200)) // 限制最大高度為 200點
                                .padding(.horizontal, 12)
                                .padding(.bottom, mainGeometry.size.height * 0.16)
                            }
                            .frame(width: mainGeometry.size.width, height: mainGeometry.size.height)
                        }
                    }
                    
                    // Floating emoji layer
                    FloatingEmojiContainer(isVisible: $showEmoji, position: emojiPosition)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .onAppear {
                // Initialize the vibration setting with a default value of true
                // We'll read from UserDefaults directly to avoid the wrapper issue
                if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
                    // If the key doesn't exist yet, it will default to true
                    self.isVibrationEnabled = userDefaults.object(forKey: "vibrationEnabled") == nil ? true : userDefaults.bool(forKey: "vibrationEnabled")
                }
            }
        }
    }
        
        
        
    }


#Preview {
    ContentView()
        .environmentObject(PanicStore())
}
