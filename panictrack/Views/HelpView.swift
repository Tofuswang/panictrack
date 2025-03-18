import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(LocalizedStringKey("help.basic.1"))
                    Text(LocalizedStringKey("help.basic.2"))
                } header: {
                    Text(LocalizedStringKey("help.basic.title"))
                }
                
                Section {
                    Text(LocalizedStringKey("help.stats.1"))
                    Text(LocalizedStringKey("help.stats.2"))
                    Text(LocalizedStringKey("help.stats.3"))
                    Text(LocalizedStringKey("help.stats.4"))
                } header: {
                    Text(LocalizedStringKey("help.stats.title"))
                }
                
                Section {
                    Text(LocalizedStringKey("help.export.1"))
                    Text(LocalizedStringKey("help.export.2"))
                    Text(LocalizedStringKey("help.export.3"))
                } header: {
                    Text(LocalizedStringKey("help.export.title"))
                }
            }
            .navigationTitle(LocalizedStringKey("help.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("help.done")) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .tint(.white)
        }
    }
}
