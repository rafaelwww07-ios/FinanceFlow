//
//  FinanceFlowWidgetLiveActivity.swift
//  FinanceFlowWidget
//
//  Created by Rafael Mukhametov on 26.11.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FinanceFlowWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FinanceFlowWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FinanceFlowWidgetAttributes.self) { context in
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

extension FinanceFlowWidgetAttributes {
    fileprivate static var preview: FinanceFlowWidgetAttributes {
        FinanceFlowWidgetAttributes(name: "World")
    }
}

extension FinanceFlowWidgetAttributes.ContentState {
    fileprivate static var smiley: FinanceFlowWidgetAttributes.ContentState {
        FinanceFlowWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FinanceFlowWidgetAttributes.ContentState {
         FinanceFlowWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FinanceFlowWidgetAttributes.preview) {
   FinanceFlowWidgetLiveActivity()
} contentStates: {
    FinanceFlowWidgetAttributes.ContentState.smiley
    FinanceFlowWidgetAttributes.ContentState.starEyes
}
