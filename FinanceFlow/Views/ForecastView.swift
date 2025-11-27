//
//  ForecastView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import Charts

struct ForecastView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    
    @State private var forecastMonths: Int = 3
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Forecast Period Picker
                    Picker("Forecast Period", selection: $forecastMonths) {
                        Text("1 Month").tag(1)
                        Text("3 Months").tag(3)
                        Text("6 Months").tag(6)
                        Text("12 Months").tag(12)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Forecast Chart
                    ForecastChartView(
                        transactions: transactionViewModel.transactions,
                        months: forecastMonths,
                        currencyCode: currencyCode
                    )
                    
                    // Forecast Details
                    ForecastDetailsView(
                        transactions: transactionViewModel.transactions,
                        months: forecastMonths,
                        currencyCode: currencyCode
                    )
                }
                .padding()
            }
            .navigationTitle("Spending Forecast")
        }
    }
}

struct ForecastChartView: View {
    let transactions: [TransactionEntity]
    let months: Int
    let currencyCode: String
    
    var forecastData: [ForecastDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var data: [ForecastDataPoint] = []
        
        // Historical data (last 3 months)
        for i in 0..<3 {
            guard let date = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? date
            
            let monthTransactions = transactions.filter { transaction in
                guard let transactionDate = transaction.date,
                      transaction.transactionType == .expense else { return false }
                return transactionDate >= monthStart && transactionDate < monthEnd
            }
            
            let total = monthTransactions.reduce(0) { $0 + $1.amount }
            data.append(ForecastDataPoint(
                date: monthStart,
                amount: total,
                isForecast: false
            ))
        }
        
        // Calculate average
        let historicalAverage = data.map { $0.amount }.reduce(0, +) / Double(data.count)
        
        // Forecast data
        for i in 1...months {
            guard let date = calendar.date(byAdding: .month, value: i, to: now) else { continue }
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
            
            // Simple forecast: use average with trend
            let trend = data.count > 1 ? (data[0].amount - data[data.count - 1].amount) / Double(data.count) : 0
            let forecastAmount = max(0, historicalAverage + (trend * Double(i)))
            
            data.append(ForecastDataPoint(
                date: monthStart,
                amount: forecastAmount,
                isForecast: true
            ))
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Forecast")
                .font(.headline)
            
            Chart(forecastData) { point in
                LineMark(
                    x: .value("Month", point.date, unit: .month),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(point.isForecast ? Color.orange : Color.blue)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Month", point.date, unit: .month),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [point.isForecast ? Color.orange.opacity(0.3) : Color.blue.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ForecastDetailsView: View {
    let transactions: [TransactionEntity]
    let months: Int
    let currencyCode: String
    
    var forecastSummary: (total: Double, average: Double, projected: Double) {
        let calendar = Calendar.current
        let now = Date()
        
        // Historical average
        var historicalTotals: [Double] = []
        for i in 0..<3 {
            guard let date = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? date
            
            let monthTransactions = transactions.filter { transaction in
                guard let transactionDate = transaction.date,
                      transaction.transactionType == .expense else { return false }
                return transactionDate >= monthStart && transactionDate < monthEnd
            }
            
            let total = monthTransactions.reduce(0) { $0 + $1.amount }
            historicalTotals.append(total)
        }
        
        let average = historicalTotals.reduce(0, +) / Double(historicalTotals.count)
        let projected = average * Double(months)
        let total = historicalTotals.reduce(0, +)
        
        return (total, average, projected)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Forecast Summary")
                .font(.headline)
            
            let summary = forecastSummary
            
            StatRow(label: "Historical Average (3 months)", value: CurrencyFormatter.format(summary.average, currencyCode: currencyCode))
            StatRow(label: "Projected Total (\(months) months)", value: CurrencyFormatter.format(summary.projected, currencyCode: currencyCode))
            StatRow(label: "Monthly Projection", value: CurrencyFormatter.format(summary.average, currencyCode: currencyCode))
            
            Divider()
            
            Text("Based on your spending patterns over the last 3 months, this forecast estimates your future expenses.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ForecastDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let isForecast: Bool
}



