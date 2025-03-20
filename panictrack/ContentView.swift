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
                                    
                                    // Stronger haptic feedback for milestone
                                    let todayCount = panicStore.entriesForDate(Date()).count
                                    // Use the local state variable for vibration setting
                                    
                                    if todayCount % 1 == 0 && todayCount > 0 {
                                        // Double haptic for milestone if vibration is enabled
                                        if isVibrationEnabled {
                                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                                            generator.impactOccurred()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                generator.impactOccurred()
                                            }
                                        }
                                        
                                        // Show encouraging emoji from button center
                                        emojiPosition = CGPoint(
                                            x: mainGeometry.frame(in: .global).midX,
                                            y: mainGeometry.frame(in: .global).midY + mainGeometry.size.height * 0.1
                                        )
                                        showEmoji = true
                                    } else if isVibrationEnabled {
                                        // Normal haptic feedback if vibration is enabled
                                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                                        generator.impactOccurred()
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
