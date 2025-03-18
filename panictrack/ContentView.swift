import SwiftUI

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @EnvironmentObject var panicStore: PanicStore
    @State private var showingHelp = false
    @State private var showEmoji = false
    @State private var emojiPosition: CGPoint = .zero
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        // Title section with black background
                        ZStack {
                            Color.black
                                .frame(height: 100)
                                .edgesIgnoringSafeArea(.top)
                            
                            HStack {
                                Text(LocalizedStringKey("content.title"))
                                    .font(.system(size: 36, weight: .bold))
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
                            .padding(.top, 45)
                        }
                        
                        // Main content area with panic button and stats
                        VStack(spacing: 120) {
                            Spacer()
                            
                            // Large rectangular panic button - takes up 1/3 of available height
                            VStack {
                                GeometryReader { buttonGeometry in
                                    PanicButton {
                                        panicStore.addEntry()
                                        
                                        // Stronger haptic feedback for milestone
                                        let todayCount = panicStore.entriesForDate(Date()).count
                                        if todayCount % 1 == 0 && todayCount > 0 {
                                            // Double haptic for milestone
                                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                                            generator.impactOccurred()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                generator.impactOccurred()
                                            }
                                            
                                            // Show encouraging emoji from button center
                                            emojiPosition = CGPoint(
                                                x: buttonGeometry.frame(in: .global).midX,
                                                y: buttonGeometry.frame(in: .global).midY
                                            )
                                            showEmoji = true
                                        } else {
                                            // Normal haptic feedback
                                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                                            generator.impactOccurred()
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                }
                            }
                            .padding(.horizontal, 12)
                            
                            Spacer()
                            
                            // Stats view at the bottom
                            StatsView(
                                todayCount: panicStore.entriesForDate(Date()).count,
                                weekCount: panicStore.entriesForLastNDays(7).count
                            )
                            .padding(.bottom, 20)
                            .padding(.horizontal, 12)
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
        }
    }
        
        
        
    }


#Preview {
    ContentView()
        .environmentObject(PanicStore())
}
