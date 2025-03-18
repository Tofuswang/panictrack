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
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        StatisticsExportView()
                    } label: {
                        Label(LocalizedStringKey("settings.stats"), systemImage: "chart.bar.doc.horizontal")
                    }
                } header: {
                    Text(LocalizedStringKey("settings.data"))
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
            }
            .navigationTitle(LocalizedStringKey("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
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
                        showExportMessage = false
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
                }
                
                // Large, easily tappable button similar to main panic button
Button(action: {
                    isPreparingCSV = true
                    // 在背景執行 CSV 匯出
                    Task {
                        let csv = panicStore.exportToCSV()
                        if let data = csv.data(using: .utf8) {
                            let tempDir = FileManager.default.temporaryDirectory
                            let fileURL = tempDir.appendingPathComponent("焦慮統計.csv")
                            try? data.write(to: fileURL)
                            csvURL = fileURL
                            showShareSheet = true
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                        isPreparingCSV = false
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
    }
}
