import SwiftUI

struct PanicButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
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
        }
        .padding(.horizontal, 4)
    }
}
