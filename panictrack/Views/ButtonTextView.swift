import SwiftUI

struct ButtonTextView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var buttonText: String
    @State private var isEditing = false
    
    init() {
        // Load the saved button text or use default
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack"),
           let savedText = userDefaults.string(forKey: "customButtonText") {
            _buttonText = State(initialValue: savedText)
        } else {
            _buttonText = State(initialValue: "好焦慮！") // Default text from localization
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey("button.text.title"))
                .font(.title)
                .padding(.top)
            
            Text(LocalizedStringKey("button.text.description"))
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Text input field
            TextField(LocalizedStringKey("button.text.input"), text: $buttonText, onEditingChanged: { editing in
                isEditing = editing
            })
            .font(.system(size: 24))
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Preview of the button
            Text(buttonText)
                .font(.system(size: 36))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.red)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 30)
            
            Spacer()
            
            // Save button
            Button(action: {
                saveButtonText()
                dismiss()
            }) {
                Text(LocalizedStringKey("button.text.save"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func saveButtonText() {
        // Don't save empty text
        guard !buttonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            buttonText = "好焦慮！" // Reset to default
            return
        }
        
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
            userDefaults.set(buttonText, forKey: "customButtonText")
        }
    }
}

#Preview {
    ButtonTextView()
        .preferredColorScheme(.dark)
}
