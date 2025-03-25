import SwiftUI

struct PanicButton: View {
    // 修改 action 參數，接受點擊位置
    let action: (CGPoint) -> Void
    @State private var isPressed = false
    @State private var buttonText: String = ""
    @State private var backgroundImage: UIImage? = nil
    
    var body: some View {
        Button(action: {
            // 這裡不做任何事情，因為我們在手動處理點擊
        }) {
            ZStack {
                // 背景層
                if let backgroundImage = backgroundImage {
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 420)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            // 半透明紅色覆蓋層，保持紅色按鈕的視覺一致性
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.3))
                        )
                } else {
                    Rectangle()
                        .fill(Color.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 420)
                        .cornerRadius(12)
                }
                
                // 文字層
                Text(buttonText)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 420)
            }
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
        .onAppear {
            // Load custom button text from UserDefaults
            if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
                if let customText = userDefaults.string(forKey: "customButtonText") {
                    buttonText = customText
                } else {
                    // Use localized default text
                    buttonText = NSLocalizedString("panic.button", comment: "")
                }
                
                // 載入自訂背景圖片
                if let imageData = userDefaults.data(forKey: "customButtonBackground"),
                   let image = UIImage(data: imageData) {
                    backgroundImage = image
                }
            }
        }
    }
}
