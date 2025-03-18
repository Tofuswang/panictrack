import SwiftUI

struct FloatingEmoji: View {
    let emoji: String
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0.0
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 80))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .offset(offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                // Gentle pop in effect
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    opacity = 1.0
                    scale = 1.2
                    rotation = Double.random(in: -15...15)
                }
                
                // Float up with gentle movement
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let randomX = CGFloat.random(in: -20...20)
                    let randomY = CGFloat.random(in: -120...(-100))
                    
                    withAnimation(.easeInOut(duration: 0.6)) {
                        offset = CGSize(width: randomX, height: randomY)
                        opacity = 0
                        scale = 1.4
                        rotation += Double.random(in: -20...20)
                    }
                }
            }
    }
}

struct FloatingEmojiContainer: View {
    @Binding var isVisible: Bool
    let position: CGPoint
    
    // Encouraging and supportive emojis for the milestone
    private let emojis = ["🥺"]
    
    var body: some View {
        if isVisible {
            FloatingEmoji(emoji: emojis.randomElement() ?? "🥺")
                .position(position)
                .onAppear {
                    // Keep animation duration short and sweet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isVisible = false
                    }
                }
        }
    }
}
