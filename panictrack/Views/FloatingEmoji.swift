import SwiftUI

struct FloatingEmoji: View {
    let emoji: String
    
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 80))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .offset(offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                // Quick pop-in with more impact
                withAnimation(.spring(response: 0.1, dampingFraction: 0.5, blendDuration: 0.1)) {
                    opacity = 1.0
                    scale = 1.1
                }
                
                // More energetic upward movement
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.easeOut(duration: 0.17)) {
                        opacity = 0
                        offset = CGSize(width: 0, height: -50) // More pronounced upward movement
                    }
                }
            }
    }
}

struct FloatingEmojiContainer: View {
    @Binding var isVisible: Bool
    let position: CGPoint
    
    // Changed emoji to 😫
    private let emojis = ["😫"]
    
    var body: some View {
        if isVisible {
            FloatingEmoji(emoji: emojis.randomElement() ?? "😫")
                .position(position)
                .onAppear {
                    // Gentle animation duration
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        isVisible = false
                    }
                }
        }
    }
}
