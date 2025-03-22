import SwiftUI

struct FloatingEmoji: View {
    let emoji: String
    
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var rotation: Double = -10.0  // 初始旋轉角度
    @State private var horizontalOffset: CGFloat = 0  // 水平抖動用
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 80))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .offset(x: offset.width + horizontalOffset, y: offset.height)
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))  // 添加旋轉效果
            .onAppear {
                // 更誇張的彈跳效果
                withAnimation(.spring(response: 0.1, dampingFraction: 0.4, blendDuration: 0.1)) {
                    opacity = 1.0
                    scale = 1.3  // 更大的初始彈跳
                }
                
                // 添加水平抖動效果
                withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                    horizontalOffset = 5
                }
                
                // 添加旋轉動畫
                withAnimation(.easeInOut(duration: 0.3)) {
                    rotation = 10.0  // 旋轉到另一個方向
                }
                
                // 延遲後縮小並上升
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.1)) {
                        scale = 0.9  // 縮小效果
                    }
                    
                    withAnimation(.easeOut(duration: 0.25)) {
                        opacity = 0
                        offset = CGSize(width: 0, height: -70)  // 更高的上升距離
                        rotation = -5.0  // 回旋轉
                    }
                }
            }
    }
}

struct FloatingEmojiContainer: View {
    @Binding var isVisible: Bool
    let position: CGPoint
    
    // Changed emoji to 🥺
    private let emojis = ["🥺"]
    
    var body: some View {
        ZStack {
            if isVisible {
                // 使用明確的 id 確保每次都創建新的視圖實例
                FloatingEmoji(emoji: emojis.randomElement() ?? "🥺")
                    .position(position)
                    .id(UUID()) // 添加唯一 ID 確保每次都是新實例
                    .onAppear {
                        // 延長動畫時間
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation {
                                isVisible = false
                            }
                        }
                    }
            }
        }
        // 添加一個空的背景層，確保 ZStack 始終存在
        .background(Color.clear)
        .animation(.easeInOut, value: isVisible) // 添加動畫效果當 isVisible 改變時
    }
}
