//
//  AppIntent.swift
//  PanicTrackWidget
//
//  Created by Tofus on 2025/3/19.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "設定" }
    static var description: IntentDescription { "焦慮追蹤小工具設定" }

    // 保留一個簡單的參數，但在實際使用中不會顯示
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
