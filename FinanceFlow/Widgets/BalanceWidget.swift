//
//  BalanceWidget.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import WidgetKit
import SwiftUI

struct BalanceWidget: Widget {
    let kind: String = "BalanceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BalanceProvider()) { entry in
            BalanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Balance")
        .description("Shows your current balance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BalanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(date: Date(), balance: 1250.50, currencyCode: "USD")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> ()) {
        let entry = BalanceEntry(date: Date(), balance: 1250.50, currencyCode: "USD")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceEntry>) -> ()) {
        let currentDate = Date()
        let entry = BalanceEntry(date: currentDate, balance: 1250.50, currencyCode: "USD")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct BalanceEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let currencyCode: String
}

struct BalanceWidgetEntryView: View {
    var entry: BalanceProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(CurrencyFormatter.format(entry.balance, currencyCode: entry.currencyCode))
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack {
                Image(systemName: "wallet.pass.fill")
                    .font(.caption)
                Text("FinanceFlow")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview(as: .systemSmall) {
    BalanceWidget()
} timeline: {
    BalanceEntry(date: .now, balance: 1250.50, currencyCode: "USD")
}


