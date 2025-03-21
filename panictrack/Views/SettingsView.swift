import SwiftUI

struct SettingsView: View {
    static let previewStore: PanicStore = {
        let store = PanicStore()
        // Add some sample data
        store.addEntry()
        return store
    }()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var panicStore: PanicStore
    @Environment(\.colorScheme) private var colorScheme
    // Use a state property that will be synchronized with PanicStore
    @State private var isVibrationEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        StatisticsExportView()
                            .transition(.opacity)
                    } label: {
                        Label(LocalizedStringKey("settings.stats"), systemImage: "chart.bar.doc.horizontal")
                    }
                } header: {
                    Text(LocalizedStringKey("settings.data"))
                }
                
                Section {
                    Toggle(isOn: $isVibrationEnabled) {
                        Label(LocalizedStringKey("settings.vibration"), systemImage: "iphone.radiowaves.left.and.right")
                    }
                    .tint(Color.green)
                    .onChange(of: isVibrationEnabled) { newValue in
                        // Save the setting directly to UserDefaults
                        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
                            userDefaults.set(newValue, forKey: "vibrationEnabled")
                            
                            // Trigger haptic feedback when toggle is turned ON
                            if newValue {
                                #if os(iOS)
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                #endif
                            }
                        }
                    }
                } header: {
                    Text(LocalizedStringKey("settings.preferences"))
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/Tofuswang/panictrack")!) {
                        Label(LocalizedStringKey("settings.source"), systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    
                    Link(destination: URL(string: "mailto:terry.f.wang@gmail.com")!) {
                        Label(LocalizedStringKey("settings.feedback"), systemImage: "envelope")
                    }
                    
                    Text(LocalizedStringKey("settings.version"))
                        .foregroundColor(.secondary)
                } header: {
                    Text(LocalizedStringKey("settings.about"))
                }
                
                Section {
                    Text(LocalizedStringKey("letter.title"))
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text(LocalizedStringKey("letter.content"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                } header: {
                    Text(LocalizedStringKey("letter.header"))
                }
            }
            .navigationTitle(LocalizedStringKey("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize the vibration setting from UserDefaults with a default value of true
                if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
                    // If the key doesn't exist yet, it will default to true
                    isVibrationEnabled = userDefaults.object(forKey: "vibrationEnabled") == nil ? true : userDefaults.bool(forKey: "vibrationEnabled")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("settings.done")) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .tint(.white)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(SettingsView.previewStore)
    }
    .preferredColorScheme(.dark)
}

#Preview {
    NavigationView {
        StatisticsExportView()
            .environmentObject(PanicStore())
    }
    .preferredColorScheme(.dark)
}

#if os(iOS)
import UIKit
#endif

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

struct StatisticsExportView: View {
    @EnvironmentObject var panicStore: PanicStore
    @State private var showExportMessage = false
    @State private var showShareSheet = false
    @State private var csvURL: URL? = nil
    @State private var isPreparingCSV = false
    @State private var isViewAppearing = false
    
    var body: some View {
        List {
            Section {
                // Large, easily tappable button similar to main panic button
Button(action: {
                    UIPasteboard.general.string = panicStore.exportDailyStats()
                    showExportMessage = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    // Hide the message after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showExportMessage = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.on.clipboard")
                            .font(.title2)
                        Text(LocalizedStringKey("export.today"))
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
                
                if showExportMessage {
                    Text(LocalizedStringKey("export.copied"))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .transition(.opacity)
                }
                
                // Large, easily tappable button similar to main panic button
Button(action: {
                    isPreparingCSV = true
                    // 在背景執行 CSV 匯出
                    Task {
                        await MainActor.run {
                            // 立即顯示加載狀態
                            isPreparingCSV = true
                        }
                        
                        // 將 CSV 生成移至背景線程
                        await Task.detached(priority: .userInitiated) {
                            let csv = panicStore.exportToCSV()
                            if let data = csv.data(using: .utf8) {
                                let tempDir = FileManager.default.temporaryDirectory
                                let fileURL = tempDir.appendingPathComponent("焦慮統計.csv")
                                try? data.write(to: fileURL)
                                
                                await MainActor.run {
                                    csvURL = fileURL
                                    showShareSheet = true
                                    isPreparingCSV = false
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                }
                            } else {
                                await MainActor.run {
                                    isPreparingCSV = false
                                }
                            }
                        }.value
                    }
                }) {
                    HStack {
                        if isPreparingCSV {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                        Text(LocalizedStringKey("export.excel"))
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
                .disabled(isPreparingCSV)
                

            } header: {
                Text(LocalizedStringKey("export.options"))
            } footer: {
                Text(LocalizedStringKey("export.description"))
            }
        }
        .navigationTitle(LocalizedStringKey("export.title"))
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .sheet(isPresented: $showShareSheet) {
            if let url = csvURL {
                ActivityViewController(activityItems: [url])
            }
        }
        .opacity(isViewAppearing ? 1 : 0)
        .onAppear {
            // 平滑過渡動畫
            withAnimation(.easeIn(duration: 0.3)) {
                isViewAppearing = true
            }
        }
        .onDisappear {
            isViewAppearing = false
        }
    }
}
