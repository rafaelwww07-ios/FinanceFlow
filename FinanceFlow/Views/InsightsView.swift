//
//  InsightsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @State private var showingAdvancedAnalytics = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Spending Trends
                    SpendingTrendsCard(transactionViewModel: transactionViewModel)
                    
                    // Top Categories
                    TopCategoriesCard(transactionViewModel: transactionViewModel, categoryViewModel: categoryViewModel)
                    
                    // Monthly Comparison
                    MonthlyComparisonCard(transactionViewModel: transactionViewModel)
                    
                    // Insights
                    InsightsCard(transactionViewModel: transactionViewModel)
                }
                .padding()
            }
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdvancedAnalytics = true
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                }
            }
            .sheet(isPresented: $showingAdvancedAnalytics) {
                AdvancedAnalyticsView(transactionViewModel: transactionViewModel)
            }
        }
    }
}

struct SpendingTrendsCard: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Trends")
                .font(.headline)
            
            let monthlyData = getMonthlySpending()
            
            if monthlyData.isEmpty {
                Text("Not enough data")
                    .foregroundColor(.secondary)
            } else {
                Chart(monthlyData, id: \.month) { data in
                    BarMark(
                        x: .value("Month", data.month, unit: .month),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(Color.red)
                    .cornerRadius(4)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func getMonthlySpending() -> [MonthlyData] {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [Date: Double] = [:]
        
        for transaction in transactionViewModel.transactions {
            guard let date = transaction.date,
                  transaction.transactionType == .expense else { continue }
            
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
            monthlyData[monthStart, default: 0] += transaction.amount
        }
        
        return monthlyData.map { MonthlyData(month: $0.key, amount: $0.value) }
            .sorted { $0.month < $1.month }
            .suffix(6)
    }
}

struct TopCategoriesCard: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Spending Categories")
                .font(.headline)
            
            let topCategories = getTopCategories()
            
            if topCategories.isEmpty {
                Text("No data")
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(topCategories.prefix(5)), id: \.category.id) { item in
                    HStack {
                        if let category = categoryViewModel.categories.first(where: { $0.id == item.category.id }) {
                            ZStack {
                                Circle()
                                    .fill(Color.fromHex(category.colorHex ?? "#000000").opacity(0.2))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: category.icon ?? "questionmark.circle")
                                    .foregroundColor(Color.fromHex(category.colorHex ?? "#000000"))
                                    .font(.caption)
                            }
                        }
                        
                        Text(item.category.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(formatCurrency(item.amount))
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func getTopCategories() -> [(category: CategoryModel, amount: Double)] {
        var categoryAmounts: [UUID: (category: CategoryModel, amount: Double)] = [:]
        
        for transaction in transactionViewModel.transactions {
            guard let category = transaction.category,
                  let categoryId = category.id,
                  transaction.transactionType == .expense else { continue }
            
            let categoryModel = category.categoryModel
            categoryAmounts[categoryId, default: (categoryModel, 0)].amount += transaction.amount
        }
        
        return categoryAmounts.values.sorted { $0.amount > $1.amount }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyFormatter.format(amount, currencyCode: currencyCode)
    }
}

struct MonthlyComparisonCard: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Comparison")
                .font(.headline)
            
            let currentMonth = getMonthlyTotal(for: Date())
            let lastMonth = getMonthlyTotal(for: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date())
            let difference = currentMonth - lastMonth
            let percentage = lastMonth > 0 ? (difference / lastMonth) * 100 : 0
            
            HStack {
                VStack(alignment: .leading) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(CurrencyFormatter.format(currentMonth, currencyCode: currencyCode, maximumFractionDigits: 0))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("vs Last Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(difference >= 0 ? "+" : "")\(CurrencyFormatter.format(difference, currencyCode: currencyCode, maximumFractionDigits: 0))")
                        .font(.headline)
                        .foregroundColor(difference >= 0 ? .red : .green)
                    Text("\(String(format: "%.1f", percentage))%")
                        .font(.caption)
                        .foregroundColor(difference >= 0 ? .red : .green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func getMonthlyTotal(for date: Date) -> Double {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? date
        
        return transactionViewModel.transactions
            .filter { transaction in
                guard let transactionDate = transaction.date,
                      transaction.transactionType == .expense else { return false }
                return transactionDate >= monthStart && transactionDate < monthEnd
            }
            .reduce(0) { $0 + $1.amount }
    }
}

struct InsightsCard: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.headline)
            
            let insights = generateInsights()
            
            ForEach(insights, id: \.self) { insight in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    
                    Text(insight)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func generateInsights() -> [String] {
        var insights: [String] = []
        
        let calendar = Calendar.current
        let now = Date()
        let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? now
        
        let thisMonthExpenses = transactionViewModel.transactions
            .filter { $0.date ?? Date() >= thisMonthStart && $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
        
        let lastMonthExpenses = transactionViewModel.transactions
            .filter { transaction in
                guard let date = transaction.date else { return false }
                return date >= lastMonthStart && date < thisMonthStart && transaction.transactionType == .expense
            }
            .reduce(0) { $0 + $1.amount }
        
        if thisMonthExpenses > lastMonthExpenses && lastMonthExpenses > 0 {
            let increase = ((thisMonthExpenses - lastMonthExpenses) / lastMonthExpenses) * 100
            insights.append("Your spending increased by \(String(format: "%.1f", increase))% compared to last month.")
        } else if thisMonthExpenses < lastMonthExpenses && lastMonthExpenses > 0 {
            let decrease = ((lastMonthExpenses - thisMonthExpenses) / lastMonthExpenses) * 100
            insights.append("Great job! Your spending decreased by \(String(format: "%.1f", decrease))% compared to last month.")
        }
        
        let averageDaily = thisMonthExpenses / Double(calendar.component(.day, from: now))
        insights.append("You're spending an average of \(CurrencyFormatter.format(averageDaily, currencyCode: currencyCode, maximumFractionDigits: 0)) per day this month.")
        
        return insights
    }
}

struct MonthlyData {
    let month: Date
    let amount: Double
}

#Preview {
    InsightsView()
}

