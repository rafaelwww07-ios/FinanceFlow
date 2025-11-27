//
//  AppIntent.swift
//  FinanceFlowWidget
//
//  Created by Rafael Mukhametov on 26.11.2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }
}
