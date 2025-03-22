import SwiftUI

struct LetterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey("letter.title"))
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text(LocalizedStringKey("letter.content"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 40)
                    
                    // Blog Card
                    Button(action: {
                        if let url = URL(string: "https://blog.tofuswang.com") {
                            openURL(url)
                        }
                    }) {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "doc.text.image")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text(LocalizedStringKey("blog.title"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.white)
                            }
                            
                            Text(LocalizedStringKey("blog.description"))
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red.opacity(0.9), Color.black.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("letter.header"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text(LocalizedStringKey("settings.done"))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .tint(.white)
    }
}

#Preview {
    LetterView()
        .preferredColorScheme(.dark)
}
