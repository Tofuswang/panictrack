import SwiftUI

struct EmojiParticle: View {
    let emoji: String
    @State private var offset: CGFloat = 50 // 起始位置往下一點
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            Text(emoji)
                .font(.system(size: 100))
                .position(x: geometry.size.width/2, y: geometry.size.height/4 + offset) // 變成 1/4 高度
                .opacity(opacity)
                .scaleEffect(scale)
                .onAppear {
                    // 快速彈出
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                        scale = 1.0
                        opacity = 1.0
                        offset = 0 // 彈到中間位置
                    }
                    
                    // 向上飄並消失
                    withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                        offset = -150 // 飄得更遠
                        opacity = 0
                    }
                }
        }
    }
}
