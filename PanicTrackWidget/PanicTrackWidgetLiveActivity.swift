//
//  PanicTrackWidgetLiveActivity.swift
//  PanicTrackWidget
//
//  Created by Tofus on 2025/3/19.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PanicTrackWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PanicTrackWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PanicTrackWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PanicTrackWidgetAttributes {
    fileprivate static var preview: PanicTrackWidgetAttributes {
        PanicTrackWidgetAttributes(name: "World")
    }
}

extension PanicTrackWidgetAttributes.ContentState {
    fileprivate static var smiley: PanicTrackWidgetAttributes.ContentState {
        PanicTrackWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PanicTrackWidgetAttributes.ContentState {
         PanicTrackWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PanicTrackWidgetAttributes.preview) {
   PanicTrackWidgetLiveActivity()
} contentStates: {
    PanicTrackWidgetAttributes.ContentState.smiley
    PanicTrackWidgetAttributes.ContentState.starEyes
}
