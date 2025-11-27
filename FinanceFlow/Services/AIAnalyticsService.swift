//
//  AIAnalyticsService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation

class AIAnalyticsService {
    static let shared = AIAnalyticsService()
    
    private init() {}
    
    // MARK: - Spending Insights
    func generateSpendingInsights(transactions: [TransactionEntity]) -> [String] {
        var insights: [String] = []
        
        let calendar = Calendar.current
        let now = Date()
        let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? now
        
        let thisMonthExpenses = transactions
            .filter { $0.date ?? Date() >= thisMonthStart && $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
        
        let lastMonthExpenses = transactions
            .filter { transaction in
                guard let date = transaction.date else { return false }
                return date >= lastMonthStart && date < thisMonthStart && transaction.transactionType == .expense
            }
            .reduce(0) { $0 + $1.amount }
        
        // Trend analysis
        if thisMonthExpenses > lastMonthExpenses && lastMonthExpenses > 0 {
            let increase = ((thisMonthExpenses - lastMonthExpenses) / lastMonthExpenses) * 100
            insights.append("⚠️ Your spending increased by \(String(format: "%.1f", increase))% this month. Consider reviewing your budget.")
        } else if thisMonthExpenses < lastMonthExpenses && lastMonthExpenses > 0 {
            let decrease = ((lastMonthExpenses - thisMonthExpenses) / lastMonthExpenses) * 100
            insights.append("✅ Great job! You saved \(String(format: "%.1f", decrease))% compared to last month.")
        }
        
        // Category analysis
        var categoryTotals: [String: Double] = [:]
        for transaction in transactions.filter({ $0.date ?? Date() >= thisMonthStart && $0.transactionType == .expense }) {
            let categoryName = transaction.category?.name ?? "Unknown"
            categoryTotals[categoryName, default: 0] += transaction.amount
        }
        
        if let topCategory = categoryTotals.max(by: { $0.value < $1.value }) {
            let percentage = (topCategory.value / thisMonthExpenses) * 100
            insights.append("📊 Your biggest expense category is \(topCategory.key) (\(String(format: "%.1f", percentage))% of total).")
        }
        
        // Daily average
        let daysInMonth = calendar.component(.day, from: now)
        let dailyAverage = thisMonthExpenses / Double(daysInMonth)
        insights.append("💰 You're spending an average of \(CurrencyFormatter.format(dailyAverage, currencyCode: "USD")) per day this month.")
        
        // Savings opportunity
        if let topCategory = categoryTotals.max(by: { $0.value < $1.value }), topCategory.value > thisMonthExpenses * 0.3 {
            insights.append("💡 Tip: Consider reducing spending on \(topCategory.key) to save more.")
        }
        
        return insights
    }
    
    // MARK: - Recommendations
    func generateRecommendations(transactions: [TransactionEntity], budgets: [BudgetEntity], transactionViewModel: TransactionViewModel) -> [String] {
        var recommendations: [String] = []
        
        // Budget recommendations
        let budgetViewModel = BudgetViewModel(transactionViewModel: transactionViewModel)
        for budget in budgets {
            let spent = budgetViewModel.getSpentAmount(for: budget, period: budget.budgetPeriod ?? .monthly)
            let remaining = budget.amount - spent
            let progress = spent / budget.amount
            
            if progress > 0.9 {
                recommendations.append("⚠️ You've used \(Int(progress * 100))% of your \(budget.category?.name ?? "budget"). Only \(CurrencyFormatter.format(remaining, currencyCode: "USD")) left.")
            }
        }
        
        // Spending pattern recommendations
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        
        let weekExpenses = transactions
            .filter { transaction in
                guard let date = transaction.date,
                      date >= weekStart,
                      transaction.transactionType == .expense else { return false }
                return true
            }
            .reduce(0) { $0 + $1.amount }
        
        if weekExpenses > 1000 {
            recommendations.append("💸 Your weekly spending is high. Try to reduce unnecessary expenses.")
        }
        
        return recommendations
    }
    
    // MARK: - Spending Predictions
    func predictNextMonthSpending(transactions: [TransactionEntity]) -> Double {
        let calendar = Calendar.current
        let now = Date()
        var monthlyTotals: [Double] = []
        
        // Собираем данные за последние 3 месяца
        for i in 1...3 {
            guard let monthStart = calendar.date(byAdding: .month, value: -i, to: now),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { continue }
            
            let monthTotal = transactions
                .filter { transaction in
                    guard let date = transaction.date,
                          date >= monthStart && date < monthEnd,
                          transaction.transactionType == .expense else { return false }
                    return true
                }
                .reduce(0) { $0 + $1.amount }
            
            monthlyTotals.append(monthTotal)
        }
        
        // Простое среднее для прогноза
        if monthlyTotals.isEmpty {
            return 0
        }
        
        let average = monthlyTotals.reduce(0, +) / Double(monthlyTotals.count)
        
        // Учитываем тренд
        if monthlyTotals.count >= 2 {
            let trend = monthlyTotals[0] - monthlyTotals[monthlyTotals.count - 1]
            return max(0, average + (trend * 0.3)) // Консервативный прогноз
        }
        
        return average
    }
}


