import SwiftUI

struct TitleTextView: View {
    @State private var titleText: String = ""
    @State private var showingSuccessAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey("title.text.header"))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            // 預覽區域
            VStack {
                ZStack {
                    Color.black
                        .frame(height: 80)
                    
                    HStack {
                        Text(titleText)
                            .font(.system(size: 33, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "info.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(.trailing)
                    }
                    .padding(.top, 40)
                }
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // 輸入區域
            VStack(alignment: .leading) {
                Text(LocalizedStringKey("title.text.input"))
                    .font(.headline)
                    .padding(.horizontal)
                
                TextField("", text: $titleText)
                    .font(.title3)
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            
            // 按鈕區域
            Button(action: {
                // 儲存自訂標題到 UserDefaults
                if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
                    userDefaults.set(titleText, forKey: "customTitleText")
                    showingSuccessAlert = true
                }
            }) {
                Text(LocalizedStringKey("title.text.save"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // 重置按鈕
            if UserDefaults(suiteName: "group.com.tofus.panictrack")?.string(forKey: "customTitleText") != nil {
                Button(action: {
                    // 移除自訂標題
                    UserDefaults(suiteName: "group.com.tofus.panictrack")?.removeObject(forKey: "customTitleText")
                    // 重置為本地化預設值
                    titleText = NSLocalizedString("content.title", comment: "")
                    showingSuccessAlert = true
                }) {
                    Text(LocalizedStringKey("title.text.reset"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(12)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text(LocalizedStringKey("title.text.success")),
                message: Text(LocalizedStringKey("title.text.success.message")),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle(LocalizedStringKey("title.text.header"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            // 載入自訂標題或使用預設值
            if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack"),
               let customTitle = userDefaults.string(forKey: "customTitleText") {
                titleText = customTitle
            } else {
                // 使用本地化預設值
                titleText = NSLocalizedString("content.title", comment: "")
            }
        }
    }
}

#Preview {
    NavigationView {
        TitleTextView()
    }
    .preferredColorScheme(.dark)
}
