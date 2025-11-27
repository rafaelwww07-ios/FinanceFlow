//
//  HeatmapView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import Charts

struct HeatmapView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Year/Month Picker
                    HStack {
                        Picker("Year", selection: $selectedYear) {
                            ForEach(2020...2030, id: \.self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        
                        Picker("Month", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                            }
                        }
                    }
                    .padding()
                    
                    // Heatmap
                    ExpenseHeatmap(
                        transactions: transactionViewModel.transactions,
                        year: selectedYear,
                        month: selectedMonth,
                        currencyCode: currencyCode
                    )
                    
                    // Statistics
                    HeatmapStatsView(
                        transactions: transactionViewModel.transactions,
                        year: selectedYear,
                        month: selectedMonth,
                        currencyCode: currencyCode
                    )
                }
                .padding()
            }
            .navigationTitle("Spending Heatmap")
        }
    }
}

struct ExpenseHeatmap: View {
    let transactions: [TransactionEntity]
    let year: Int
    let month: Int
    let currencyCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Spending")
                .font(.headline)
            
            let calendar = Calendar.current
            let dateComponents = DateComponents(year: year, month: month, day: 1)
            
            if let monthStart = calendar.date(from: dateComponents),
               let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) {
                let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
                let firstWeekday = calendar.component(.weekday, from: monthStart)
                
                let dailyTotals = getDailyTotals(monthStart: monthStart, monthEnd: monthEnd)
                let maxAmount = dailyTotals.values.max() ?? 1
                
                VStack(spacing: 4) {
                    // Weekday headers
                    HStack(spacing: 4) {
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Calendar grid
                    VStack(spacing: 4) {
                        ForEach(0..<6) { week in
                            HStack(spacing: 4) {
                                ForEach(0..<7) { day in
                                    let dayIndex = week * 7 + day
                                    if dayIndex >= firstWeekday - 1 && dayIndex < firstWeekday - 1 + daysInMonth {
                                        let actualDay = dayIndex - (firstWeekday - 1) + 1
                                        let date = calendar.date(byAdding: .day, value: actualDay - 1, to: monthStart)!
                                        let amount = dailyTotals[actualDay] ?? 0
                                        let intensity = maxAmount > 0 ? min(amount / maxAmount, 1.0) : 0
                                        
                                        VStack(spacing: 2) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.blue.opacity(intensity))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Text("\(actualDay)")
                                                        .font(.caption2)
                                                        .foregroundColor(intensity > 0.5 ? .white : .primary)
                                                )
                                            
                                            if amount > 0 {
                                                Text(CurrencyFormatter.format(amount, currencyCode: currencyCode, maximumFractionDigits: 0))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    } else {
                                        Spacer()
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Invalid date")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func getDailyTotals(monthStart: Date, monthEnd: Date) -> [Int: Double] {
        var totals: [Int: Double] = [:]
        let calendar = Calendar.current
        
        for transaction in transactions {
            guard let date = transaction.date,
                  date >= monthStart && date < monthEnd,
                  transaction.transactionType == .expense else { continue }
            
            let day = calendar.component(.day, from: date)
            totals[day, default: 0] += transaction.amount
        }
        
        return totals
    }
}

struct HeatmapStatsView: View {
    let transactions: [TransactionEntity]
    let year: Int
    let month: Int
    let currencyCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
            
            let stats = calculateStats()
            
            StatRow(label: "Total Spent", value: CurrencyFormatter.format(stats.total, currencyCode: currencyCode))
            StatRow(label: "Average per Day", value: CurrencyFormatter.format(stats.average, currencyCode: currencyCode))
            StatRow(label: "Highest Day", value: CurrencyFormatter.format(stats.highest, currencyCode: currencyCode))
            StatRow(label: "Days with Expenses", value: "\(stats.daysWithExpenses)")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func calculateStats() -> (total: Double, average: Double, highest: Double, daysWithExpenses: Int) {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let monthStart = calendar.date(from: dateComponents),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return (0, 0, 0, 0)
        }
        
        let monthTransactions = transactions.filter { transaction in
            guard let date = transaction.date,
                  date >= monthStart && date < monthEnd,
                  transaction.transactionType == .expense else { return false }
            return true
        }
        
        var dailyTotals: [Int: Double] = [:]
        for transaction in monthTransactions {
            guard let date = transaction.date else { continue }
            let day = calendar.component(.day, from: date)
            dailyTotals[day, default: 0] += transaction.amount
        }
        
        let total = dailyTotals.values.reduce(0, +)
        let daysWithExpenses = dailyTotals.count
        let average = daysWithExpenses > 0 ? total / Double(daysWithExpenses) : 0
        let highest = dailyTotals.values.max() ?? 0
        
        return (total, average, highest, daysWithExpenses)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}

