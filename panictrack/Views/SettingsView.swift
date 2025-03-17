import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var panicStore: PanicStore
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        StatisticsExportView(panicStore: panicStore)
                    } label: {
                        Label("統計資料", systemImage: "chart.bar.doc.horizontal")
                    }
                } header: {
                    Text("資料管理")
                }
                
                Section {
                    NavigationLink {
                        Text("即將推出")
                            .foregroundColor(.secondary)
                    } label: {
                        Label("小工具", systemImage: "hammer")
                    }
                    
                    NavigationLink {
                        Text("即將推出")
                            .foregroundColor(.secondary)
                    } label: {
                        Label("通知設定", systemImage: "bell")
                    }
                } header: {
                    Text("功能")
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/Tofuswang/panictrack")!) {
                        Label("原始碼", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    
                    Link(destination: URL(string: "mailto:terry.f.wang@gmail.com")!) {
                        Label("意見回饋", systemImage: "envelope")
                    }
                    
                    Text("版本 1.0.0")
                        .foregroundColor(.secondary)
                } header: {
                    Text("關於")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .tint(.white)
        }
    }
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
    @ObservedObject var panicStore: PanicStore
    @State private var exportMessage: String? = nil
    @State private var showShareSheet = false
    @State private var csvURL: URL? = nil
    @State private var isPreparingCSV = false
    
    var body: some View {
        List {
            Section {
                Button(action: {
                    UIPasteboard.general.string = panicStore.exportDailyStats()
                    exportMessage = "已複製到剪貼簿"
                }) {
                    Label("匯出今日統計", systemImage: "doc.on.clipboard")
                }
                
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
                        }
                        isPreparingCSV = false
                    }
                }) {
                    HStack {
                        if isPreparingCSV {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Label("分享 Excel 表格", systemImage: "square.and.arrow.up")
                    }
                }
                .disabled(isPreparingCSV)
                
                if let message = exportMessage {
                    Text(message)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            } header: {
                Text("匯出選項")
            } footer: {
                Text("選擇合適的匯出格式，Excel 表格包含所有歷史統計資料")
            }
        }
        .navigationTitle("統計資料")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .sheet(isPresented: $showShareSheet) {
            if let url = csvURL {
                ActivityViewController(activityItems: [url])
            }
        }
    }
}

