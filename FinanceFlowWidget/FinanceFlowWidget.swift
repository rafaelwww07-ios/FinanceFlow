//
//  FinanceFlowWidget.swift
//  FinanceFlowWidget
//
//  Created by Rafael Mukhametov on 26.11.2025.
//

import WidgetKit
import SwiftUI
import CoreData

// Импортируем Core Data модели из основного приложения
// TransactionEntity будет доступен после добавления FinanceFlowModel.xcdatamodeld в таргет виджета

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(
            date: Date(),
            totalBalance: 1250.50,
            monthlyIncome: 5000.0,
            monthlyExpense: 3749.50,
            currencyCode: "USD"
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> BalanceEntry {
        getCurrentEntry()
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<BalanceEntry> {
        let entry = getCurrentEntry()
        // Обновляем каждые 15 минут
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    private func getCurrentEntry() -> BalanceEntry {
        let persistenceController = SharedPersistenceController.shared
        let context = persistenceController.container.viewContext
        
        // Используем общий fetch request для NSManagedObject
        let entityName = "TransactionEntity"
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        var totalBalance: Double = 0
        var monthlyIncome: Double = 0
        var monthlyExpense: Double = 0
        
        do {
            let transactions = try context.fetch(fetchRequest)
            let calendar = Calendar.current
            let now = Date()
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            
            for transaction in transactions {
                // Получаем значения через KVC (Key-Value Coding)
                guard let amount = transaction.value(forKey: "amount") as? Double else { continue }
                let type = transaction.value(forKey: "type") as? String ?? "expense"
                let date = transaction.value(forKey: "date") as? Date
                
                if type == "income" {
                    totalBalance += amount
                    if let date = date, date >= monthStart {
                        monthlyIncome += amount
                    }
                } else {
                    totalBalance -= amount
                    if let date = date, date >= monthStart {
                        monthlyExpense += amount
                    }
                }
            }
        } catch {
            print("Error fetching transactions for widget: \(error)")
        }
        
        let currencyCode = UserDefaults(suiteName: "group.com.financeflow.app")?.string(forKey: "currencyCode") ?? "USD"
        
        return BalanceEntry(
            date: Date(),
            totalBalance: totalBalance,
            monthlyIncome: monthlyIncome,
            monthlyExpense: monthlyExpense,
            currencyCode: currencyCode
        )
    }
}

struct BalanceEntry: TimelineEntry {
    let date: Date
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpense: Double
    let currencyCode: String
}

struct FinanceFlowWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallBalanceWidget(entry: entry)
        case .systemMedium:
            MediumBalanceWidget(entry: entry)
        case .systemLarge:
            LargeBalanceWidget(entry: entry)
        default:
            SmallBalanceWidget(entry: entry)
        }
    }
}

struct SmallBalanceWidget: View {
    let entry: BalanceEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(entry.totalBalance))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(entry.totalBalance >= 0 ? .primary : .red)
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Income")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(entry.monthlyIncome))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Expense")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(entry.monthlyExpense))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = entry.currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct MediumBalanceWidget: View {
    let entry: BalanceEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(entry.totalBalance))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(entry.totalBalance >= 0 ? .primary : .red)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(entry.monthlyIncome))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Expense")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(entry.monthlyExpense))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = entry.currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct LargeBalanceWidget: View {
    let entry: BalanceEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Finance Flow")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(entry.totalBalance))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(entry.totalBalance >= 0 ? .primary : .red)
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(formatCurrency(entry.monthlyIncome))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                        Text("Expense")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(formatCurrency(entry.monthlyExpense))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            let net = entry.monthlyIncome - entry.monthlyExpense
            HStack {
                Text("Net this month:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatCurrency(net))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(net >= 0 ? .green : .red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = entry.currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct FinanceFlowWidget: Widget {
    let kind: String = "FinanceFlowWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FinanceFlowWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Balance Widget")
        .description("View your total balance at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// ConfigurationAppIntent определен в AppIntent.swift

#Preview(as: .systemSmall) {
    FinanceFlowWidget()
} timeline: {
    BalanceEntry(date: .now, totalBalance: 1250.50, monthlyIncome: 5000.0, monthlyExpense: 3749.50, currencyCode: "USD")
    BalanceEntry(date: .now, totalBalance: 2000.0, monthlyIncome: 6000.0, monthlyExpense: 4000.0, currencyCode: "USD")
}
