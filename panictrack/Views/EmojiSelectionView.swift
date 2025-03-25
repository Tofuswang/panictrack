import SwiftUI

struct EmojiSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmoji: String
    @State private var customEmojis: [String] = []
    @State private var showingAddEmojiSheet = false
    @State private var showingEditMode = false
    
    // Predefined emoji options
    private let defaultEmojis = ["🥺", "😰", "😢", "😭", "😣", "😖", "😫", "😩", "🫠", "😵‍💫"]
    
    // Computed property to combine default and custom emojis
    var allEmojis: [String] {
        return defaultEmojis + customEmojis
    }
    
    init() {
        // Load the saved emoji or use default
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack"),
           let savedEmoji = userDefaults.string(forKey: "selectedEmoji") {
            _selectedEmoji = State(initialValue: savedEmoji)
        } else {
            _selectedEmoji = State(initialValue: "🥺") // Default emoji
        }
        
        // Load custom emojis
        _customEmojis = State(initialValue: loadCustomEmojis())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(LocalizedStringKey("emoji.selection.title"))
                    .font(.title)
                
                Spacer()
                
                // Edit button
                Button(action: {
                    showingEditMode.toggle()
                }) {
                    Text(LocalizedStringKey(showingEditMode ? "emoji.selection.done" : "emoji.selection.edit"))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.top)
            .padding(.horizontal)
            
            Text(LocalizedStringKey("emoji.selection.description"))
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Display emoji grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 15) {
                    ForEach(allEmojis, id: \.self) { emoji in
                        Button(action: {
                            if !showingEditMode {
                                selectedEmoji = emoji
                                saveSelectedEmoji()
                                
                                // Provide haptic feedback
                                #if os(iOS)
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                #endif
                            }
                        }) {
                            ZStack {
                                Text(emoji)
                                    .font(.system(size: 40))
                                    .frame(width: 70, height: 70)
                                    .background(selectedEmoji == emoji ? Color.red.opacity(0.3) : Color.black)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedEmoji == emoji ? Color.red : Color.gray, lineWidth: 2)
                                    )
                                
                                // Show delete button in edit mode for custom emojis
                                if showingEditMode && customEmojis.contains(emoji) {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                deleteEmoji(emoji)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(5)
                                }
                            }
                        }
                    }
                    
                    // Add button (only visible when not in edit mode)
                    if !showingEditMode {
                        Button(action: {
                            showingAddEmojiSheet = true
                        }) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Done button
            Button(LocalizedStringKey("emoji.selection.done")) {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingAddEmojiSheet) {
            AddEmojiView(onEmojiSelected: { newEmoji in
                addCustomEmoji(newEmoji)
                showingAddEmojiSheet = false
            })
        }
    }
    
    private func saveSelectedEmoji() {
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
            userDefaults.set(selectedEmoji, forKey: "selectedEmoji")
        }
    }
    
    private func loadCustomEmojis() -> [String] {
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack"),
           let savedEmojis = userDefaults.stringArray(forKey: "customEmojis") {
            return savedEmojis
        }
        return []
    }
    
    private func saveCustomEmojis() {
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
            userDefaults.set(customEmojis, forKey: "customEmojis")
        }
    }
    
    private func addCustomEmoji(_ emoji: String) {
        if !customEmojis.contains(emoji) && !defaultEmojis.contains(emoji) {
            customEmojis.append(emoji)
            saveCustomEmojis()
        }
    }
    
    private func deleteEmoji(_ emoji: String) {
        if let index = customEmojis.firstIndex(of: emoji) {
            customEmojis.remove(at: index)
            saveCustomEmojis()
            
            // If the deleted emoji was selected, select the first available emoji
            if selectedEmoji == emoji {
                selectedEmoji = allEmojis.first ?? "🥺"
                saveSelectedEmoji()
            }
        }
    }
}

// View for adding a new emoji
struct AddEmojiView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var recentlyUsedEmojis: [String] = []
    var onEmojiSelected: (String) -> Void
    
    // All emoji categories
    let emojiCategories: [(name: String, emojis: [String])] = [
        ("笑臉表情", ["😀", "😁", "😂", "😃", "😄", "😅", "😆", "😇", "😉", "😊", "😋", "😌", "😍", "😎", "😏", "😐", "😑", "😒", "😓"]),
        ("情緒表情", ["😔", "😕", "😖", "😗", "😘", "😙", "😚", "😛", "😜", "😝", "😞", "😟", "😠", "😡", "😢", "😣", "😤", "😥", "😦", "😧", "😨", "😩", "😪", "😫", "😬", "😭", "😮", "😯", "😰", "😱", "😲", "😳", "😵", "😶", "😷", "😸", "😹", "😺", "😻", "😼", "😽", "😾", "😿", "🙀", "🙁", "🙂", "🙃", "🙄", "🙅", "🙆", "🙇", "🙈", "🙉", "🙊", "🙋", "🙌", "🙍", "🙎", "🙏"]),
        ("新的表情", ["🤐", "🤑", "🤒", "🤓", "🤔", "🤕", "🤖", "🤗", "🤘", "🤙", "🤚", "🤛", "🤜", "🤝", "🤞", "🤟", "🤠", "🤡", "🤢", "🤣", "🤤", "🤥", "🤦", "🤧", "🤨", "🤩", "🤪", "🤫", "🤬", "🤭", "🤮", "🤯", "🤰", "🤱", "🤲", "🤳", "🤴", "🤵", "🤶", "🤷"]),
        ("特殊表情", ["🥰", "🥱", "🥲", "🥳", "🥴", "🥵", "🥶", "🥷", "🥸", "🥹", "🥺", "🥻", "🥼", "🥽", "🥾", "🥿", "🦀", "🦁", "🦂", "🦃", "🦄", "🦅", "🦆"]),
        ("手動作", ["👀", "👂", "👃", "👄", "👅", "👆", "👇", "👈", "👉", "👊", "👋", "👌", "👍", "👎", "👏", "👐", "👑", "👒", "👓", "👔", "👕", "👖", "👗", "👘", "👙", "👚", "👛", "👜", "👝", "👞", "👟", "👠", "👡", "👢", "👣", "👤", "👥", "👦", "👧", "👨", "👩", "👪", "👫", "👬", "👭", "👮", "👯", "👰", "👱", "👲", "👳", "👴", "👵", "👶", "👷", "👸", "👹", "👺", "👻", "👼", "👽", "👾", "👿", "🖕"]),
        ("動物", ["🐀", "🐁", "🐂", "🐃", "🐄", "🐅", "🐆", "🐇", "🐈", "🐉", "🐊", "🐋", "🐌", "🐍", "🐎", "🐏", "🐐", "🐑", "🐒", "🐓", "🐔", "🐕", "🐖", "🐗", "🐘", "🐙", "🐚", "🐛", "🐜", "🐝", "🐞", "🐟", "🐠", "🐡", "🐢", "🐣", "🐤", "🐥", "🐦", "🐧", "🐨", "🐩", "🐪", "🐫", "🐬", "🐭", "🐮", "🐯", "🐰", "🐱", "🐲", "🐳", "🐴", "🐵", "🐶", "🐷", "🐸", "🐹", "🐺", "🐻", "🐼", "🐽", "🐾", "🐿"]),
        ("食物", ["🌰", "🌱", "🌲", "🌳", "🌴", "🌵", "🌶", "🌷", "🌸", "🌹", "🌺", "🌻", "🌼", "🌽", "🌾", "🌿", "🍀", "🍁", "🍂", "🍃", "🍄", "🍅", "🍆", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🍎", "🍏", "🍐", "🍑", "🍒", "🍓", "🍔", "🍕", "🍖", "🍗", "🍘", "🍙", "🍚", "🍛", "🍜", "🍝", "🍞", "🍟", "🍠", "🍡", "🍢", "🍣", "🍤", "🍥", "🍦", "🍧", "🍨", "🍩", "🍪", "🍫", "🍬", "🍭", "🍮", "🍯", "🍰", "🍱", "🍲", "🍳", "🍴", "🍵", "🍶", "🍷", "🍸", "🍹", "🍺", "🍻", "🍼", "🍽", "🍾", "🍿"]),
        ("物品", ["💠", "💡", "💢", "💣", "💤", "💥", "💦", "💧", "💨", "💩", "💪", "💫", "💬", "💭", "💮", "💯", "💰", "💱", "💲", "💳", "💴", "💵", "💶", "💷", "💸", "💹", "💺", "💻", "💼", "💽", "💾", "💿", "📀", "📁", "📂", "📃", "📄", "📅", "📆", "📇", "📈", "📉", "📊", "📋", "📌", "📍", "📎", "📏", "📐", "📑", "📒", "📓", "📔", "📕", "📖", "📗", "📘", "📙", "📚", "📛", "📜", "📝", "📞", "📟", "📠", "📡", "📢", "📣", "📤", "📥", "📦", "📧", "📨", "📩", "📪", "📫", "📬", "📭", "📮", "📯", "📰", "📱", "📲", "📳", "📴", "📵", "📶", "📷", "📸", "📹", "📺", "📻", "📼", "📽", "📾", "📿"]),
        ("符號", ["✂️", "✅", "✈️", "✉️", "✊", "✋", "✌️", "✏️", "✒️", "✔️", "✖️", "✨", "✳️", "✴️", "❄️", "❇️", "❌", "❎", "❓", "❔", "❕", "❗", "❤️", "➕", "➖", "➗", "➡️", "➰", "➿", "⤴️", "⤵️", "⬅️", "⬆️", "⬇️", "⬛", "⬜", "⭐", "⭕", "〰️", "〽️", "㊗️", "㊙️"])
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(LocalizedStringKey("emoji.selection.add.title"))
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(LocalizedStringKey("emoji.selection.cancel")) {
                    dismiss()
                }
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            
            // Search bar
            TextField(LocalizedStringKey("emoji.selection.search"), text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            ScrollView {
                // Recently used section
                if !recentlyUsedEmojis.isEmpty && searchText.isEmpty {
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey("emoji.selection.recent"))
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 5)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                            ForEach(recentlyUsedEmojis, id: \.self) { emoji in
                                Button(action: {
                                    onEmojiSelected(emoji)
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 30))
                                        .frame(width: 50, height: 50)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.vertical, 5)
                }
                
                // Display filtered emojis or categories
                if searchText.isEmpty {
                    ForEach(emojiCategories, id: \.name) { category in
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 5)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                                ForEach(category.emojis, id: \.self) { emoji in
                                    Button(action: {
                                        addToRecentlyUsed(emoji)
                                        onEmojiSelected(emoji)
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 30))
                                            .frame(width: 50, height: 50)
                                            .background(Color.black)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .padding(.vertical, 5)
                    }
                } else {
                    // Display search results
                    let filteredEmojis = allEmojisFromCategories().filter { $0.contains(searchText) }
                    
                    if filteredEmojis.isEmpty {
                        Text(LocalizedStringKey("emoji.selection.no.results"))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                            ForEach(filteredEmojis, id: \.self) { emoji in
                                Button(action: {
                                    addToRecentlyUsed(emoji)
                                    onEmojiSelected(emoji)
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 30))
                                        .frame(width: 50, height: 50)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            loadRecentlyUsedEmojis()
        }
    }
    
    private func allEmojisFromCategories() -> [String] {
        return emojiCategories.flatMap { $0.emojis }
    }
    
    private func addToRecentlyUsed(_ emoji: String) {
        // Remove if already exists
        if let index = recentlyUsedEmojis.firstIndex(of: emoji) {
            recentlyUsedEmojis.remove(at: index)
        }
        
        // Add to the beginning
        recentlyUsedEmojis.insert(emoji, at: 0)
        
        // Limit to 10 recent emojis
        if recentlyUsedEmojis.count > 10 {
            recentlyUsedEmojis = Array(recentlyUsedEmojis.prefix(10))
        }
        
        // Save to UserDefaults
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack") {
            userDefaults.set(recentlyUsedEmojis, forKey: "recentlyUsedEmojis")
        }
    }
    
    private func loadRecentlyUsedEmojis() {
        if let userDefaults = UserDefaults(suiteName: "group.com.tofus.panictrack"),
           let saved = userDefaults.stringArray(forKey: "recentlyUsedEmojis") {
            recentlyUsedEmojis = saved
        }
    }
}

#Preview {
    EmojiSelectionView()
        .preferredColorScheme(.dark)
}
