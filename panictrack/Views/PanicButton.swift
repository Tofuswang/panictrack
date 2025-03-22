import SwiftUI

struct PanicButton: View {
    // 修改 action 參數，接受點擊位置
    let action: (CGPoint) -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // 這裡不做任何事情，因為我們在手動處理點擊
        }) {
            Text(LocalizedStringKey("panic.button"))
                .font(.system(size: 36))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                .background(Color.red)
                .cornerRadius(12)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                // 在文本內容上直接添加手動點擊處理
                .contentShape(Rectangle()) // 確保整個區域都可點擊
                .onTapGesture { location in
                    // 觸發動作並傳遞點擊位置
                    action(location)
                    
                    // 按鈕動畫效果
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
                }
        }
        .padding(.horizontal, 4)
    }
}
