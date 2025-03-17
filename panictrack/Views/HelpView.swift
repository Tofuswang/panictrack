import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("當你感到焦慮時，點擊大按鈕來記錄你的情緒。")
                    Text("每次點擊都會顯示一個表情符號，幫助你釋放壓力。")
                } header: {
                    Text("基本功能")
                }
                
                Section {
                    Text("「今日」顯示當天每小時的焦慮次數")
                    Text("「最近7天」顯示一週內每天的焦慮趨勢")
                    Text("「本月」顯示當月每週的焦慮趨勢")
                    Text("「全年」顯示全年每月的焦慮趨勢")
                } header: {
                    Text("統計圖表")
                }
                
                Section {
                    Text("在「統計數據」頁面點擊齒輪圖示")
                    Text("選擇「統計資料」可以匯出詳細的統計數據")
                    Text("可以選擇複製今日統計或匯出完整的 Excel 表格")
                } header: {
                    Text("資料匯出")
                }
            }
            .navigationTitle("使用說明")
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
