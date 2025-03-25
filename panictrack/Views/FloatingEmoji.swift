import SwiftUI

struct FloatingEmoji: View {
    let emoji: String
    let id: Int
    
    @State private var animationState: Int = 0
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 80))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .modifier(FloatingEmojiAnimationModifier(animationState: animationState))
            .onAppear {
                // Trigger the animation state changes in sequence
                animationState = 1
            }
    }
}

// Custom modifier to handle all animation states
struct FloatingEmojiAnimationModifier: ViewModifier {
    let animationState: Int
    
    // Animation properties
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var rotation: Double = -10.0
    @State private var horizontalOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: horizontalOffset, y: offset.height)
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onChange(of: animationState) { newState in
                if newState == 1 {
                    // Single animation chain using animation modifiers
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                        opacity = 1.0
                        scale = 1.2
                        horizontalOffset = 3
                        rotation = 5.0
                    }
                    
                    // Use animation completion callback instead of DispatchQueue
                    withAnimation(.easeOut(duration: 0.25).delay(0.15)) {
                        opacity = 0
                        offset = CGSize(width: 0, height: -70)
                        scale = 0.9
                        rotation = -5.0
                    }
                }
            }
    }
}

// Structure to store animation data
struct EmojiAnimation: Identifiable {
    let id: Int
    let position: CGPoint
    let emoji: String
    // Add slight randomization to make multiple animations visually distinct
    let offsetX: CGFloat
}

struct FloatingEmojiContainer: View {
    @Binding var isVisible: Bool
    let position: CGPoint
    @State private var selectedEmoji: String = "🥺"
    @State private var animationCounter = 0
    
    // Store multiple animations
    @State private var activeAnimations: [EmojiAnimation] = []
    
    var body: some View {
        ZStack {
            // Display all active animations
            ForEach(activeAnimations) { animation in
                FloatingEmoji(emoji: animation.emoji, id: animation.id)
                    .position(CGPoint(x: animation.position.x + animation.offsetX, y: animation.position.y))
            }
        }
        .background(Color.clear)
        .onChange(of: isVisible) { newValue in
            if newValue {
                // 確保每次觸發前先載入最新的表情符號設定
                loadSelectedEmoji()
                
                // Add a new animation when button is pressed
                animationCounter += 1
                
                // Create slight randomness for multiple animations
                let randomOffset = CGFloat.random(in: -20...20)
                
                let newAnimation = EmojiAnimation(
                    id: animationCounter,
                    position: position,
                    emoji: selectedEmoji,
                    offsetX: randomOffset
                )
                activeAnimations.append(newAnimation)
                
                // Immediately reset isVisible so we can receive new animations
                // This allows rapid clicking to work properly
                DispatchQueue.main.async {
                    isVisible = false
                }
                
                // Remove the animation after it completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if let index = activeAnimations.firstIndex(where: { $0.id == newAnimation.id }) {
                        activeAnimations.remove(at: index)
                    }
                }
            }
        }
        .onAppear {
            // Load custom emoji from UserDefaults
            loadSelectedEmoji()
        }
    }
    
    // 抽取載入表情符號的方法，確保每次都能獲取最新設定
    private func loadSelectedEmoji() {
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
            if let customEmoji = userDefaults.string(forKey: "selectedEmoji") {
                selectedEmoji = customEmoji
            } else {
                // 如果沒有設定，使用預設表情符號
                selectedEmoji = "🥺"
            }
        }
    }
    }

