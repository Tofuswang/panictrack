//
//  PanicTrackWidget.swift
//  PanicTrackWidget
//
//  Created by Tofus on 2025/3/19.
//

import WidgetKit
import SwiftUI
import AppIntents

// PanicStore 已在同一目錄中定義

struct RecordPanicIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("widget.record.panic", bundle: .main)
    static var description = IntentDescription(LocalizedStringResource("widget.record.description", bundle: .main))
    
    @Parameter(title: "Widget ID")
    var widgetID: String
    
    init() {
        self.widgetID = UUID().uuidString
    }
    
    init(widgetID: String) {
        self.widgetID = widgetID
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let store = PanicStore.shared
        store.addEntry()
        
        // 儲存動畫狀態到 UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.tofus.panictrack")
        defaults?.set(true, forKey: "showAnimation_\(widgetID)")
        defaults?.set(Date().timeIntervalSince1970, forKey: "animationTimestamp_\(widgetID)")
        
        // 設置震動標記，當主應用啟動時觸發震動
        defaults?.set(true, forKey: "triggerHaptic")
        defaults?.set(Date().timeIntervalSince1970, forKey: "hapticTimestamp")
        
        // 強制更新 Widget
        WidgetCenter.shared.reloadTimelines(ofKind: "PanicTrackWidget")
        
        // 打開主應用
        // 我們不能直接在 Widget 中打開應用
        // 而是設置一個標記，當用戶點擊 Widget 時將打開主應用
        
        return .result(value: widgetID)
    }
    

}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todayCount: 3, weekCount: 12, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let store = PanicStore.shared
        return SimpleEntry(
            date: Date(),
            todayCount: store.entriesForDate(Date()).count,
            weekCount: store.entriesForLastNDays(7).count,
            configuration: configuration
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let store = PanicStore.shared
        let entry = SimpleEntry(
            date: Date(),
            todayCount: store.entriesForDate(Date()).count,
            weekCount: store.entriesForLastNDays(7).count,
            configuration: configuration
        )
        
        // Update the widget every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let weekCount: Int
    let configuration: ConfigurationAppIntent
}

struct PanicTrackWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @State private var showEmoji = false
    @State private var widgetID = UUID().uuidString
    
    private var shouldShowAnimation: Bool {
        let defaults = UserDefaults(suiteName: "group.com.tofus.panictrack")
        guard let show = defaults?.bool(forKey: "showAnimation_\(widgetID)") else { return false }
        guard let timestamp = defaults?.double(forKey: "animationTimestamp_\(widgetID)") else { return false }
        
        // 只顯示最近 5 秒內的動畫
        let now = Date().timeIntervalSince1970
        let isRecent = (now - timestamp) < 5.0
        
        // 如果動畫已經顯示完畢，重置狀態
        if show && !isRecent {
            defaults?.set(false, forKey: "showAnimation_\(widgetID)")
            return false
        }
        
        return show && isRecent
    }
    
    // 根據 Widget 尺寸計算按鈕高度
    private var buttonHeight: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 100  // 增加高度，填滿小型 Widget
        case .systemMedium:
            return 80  // 縮小高度，留出合理的邊框
        case .systemLarge:
            return 260
        default:
            return 120
        }
    }
    
    // 根據 Widget 尺寸計算按鈕字體大小
    private var buttonFontSize: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 16
        case .systemMedium:
            return 24
        case .systemLarge:
            return 36
        default:
            return 24
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 先顯示數字和動畫
                if widgetFamily != .systemSmall {
                    // 中型和大型顯示完整的今日統計
                    HStack {
                        ZStack {
                            Text(LocalizedStringKey("widget.today"))
                                .font(.system(size: widgetFamily == .systemMedium ? 14 : 16, weight: .medium))
                                .foregroundColor(.white)
                                .opacity(shouldShowAnimation ? 0 : 1)
                            
                            if shouldShowAnimation {
                                Text("😰")
                                    .font(.system(size: widgetFamily == .systemMedium ? 24 : 30))
                                    .transition(.scale.combined(with: .opacity))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: shouldShowAnimation)
                            }
                        }
                        
                        Spacer()
                        Text("\(entry.todayCount)")
                            .font(.system(size: widgetFamily == .systemMedium ? 20 : 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, widgetFamily == .systemMedium ? 12 : 16)
                    .padding(.top, widgetFamily == .systemSmall ? 4 : 12)
                } else {
                    // 小型只顯示數字，但設計更緊湊
                    HStack(spacing: 2) {
                        if shouldShowAnimation {
                            Text("😰")
                                .font(.system(size: 14))
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: shouldShowAnimation)
                        } else {
                            Text(LocalizedStringKey("widget.today.short"))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        Text("\(entry.todayCount)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                }
                
                // 紅色按鈕設計
                Button(intent: RecordPanicIntent(widgetID: widgetID)) {
                    Text(LocalizedStringKey("widget.button"))
                        .font(.system(size: buttonFontSize, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, widgetFamily == .systemSmall ? 6 : (widgetFamily == .systemMedium ? 8 : 12))
                .padding(.top, widgetFamily == .systemSmall ? 2 : 10)
                .padding(.bottom, widgetFamily == .systemSmall ? 4 : 12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct PanicTrackWidget: Widget {
    let kind: String = "PanicTrackWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PanicTrackWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.black
                }
        }
        .configurationDisplayName(LocalizedStringKey("widget.title"))
        .description(LocalizedStringKey("widget.description"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
}


#Preview(as: .systemLarge) {
    PanicTrackWidget()
} timeline: {
    SimpleEntry(date: .now, todayCount: 5, weekCount: 18, configuration: .preview)
}

#Preview(as: .systemSmall) {
    PanicTrackWidget()
} timeline: {
    SimpleEntry(date: .now, todayCount: 5, weekCount: 18, configuration: .preview)
}

#Preview(as: .systemMedium) {
    PanicTrackWidget()
} timeline: {
    SimpleEntry(date: .now, todayCount: 5, weekCount: 18, configuration: .preview)
}
