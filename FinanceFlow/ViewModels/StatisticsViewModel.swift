//
//  StatisticsViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Charts
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var selectedPeriod: StatisticsPeriod = .month
    @Published var categoryStats: [CategoryStat] = []
    @Published var chartData: [ChartDataPoint] = []
    
    private let transactionViewModel: TransactionViewModel
    private let categoryViewModel: CategoryViewModel
    
    init(transactionViewModel: TransactionViewModel, categoryViewModel: CategoryViewModel) {
        self.transactionViewModel = transactionViewModel
        self.categoryViewModel = categoryViewModel
        updateStatistics()
    }
    
    func updateStatistics() {
        calculateCategoryStats()
        calculateChartData()
    }
    
    private func calculateCategoryStats() {
        let transactions = transactionViewModel.getTransactions(for: selectedPeriod)
        var categoryAmounts: [UUID: Double] = [:]
        
        for transaction in transactions {
            guard let category = transaction.category,
                  let categoryId = category.id else { continue }
            
            let amount = transaction.transactionType == .expense ? transaction.amount : 0
            categoryAmounts[categoryId, default: 0] += amount
        }
        
        categoryStats = categoryAmounts.compactMap { categoryId, amount in
            guard let category = categoryViewModel.categories.first(where: { $0.id == categoryId }),
                  amount > 0 else { return nil }
            
            return CategoryStat(
                category: category.categoryModel,
                amount: amount,
                percentage: 0 // Will calculate after
            )
        }
        .sorted { $0.amount > $1.amount }
        
        let total = categoryStats.reduce(0) { $0 + $1.amount }
        categoryStats = categoryStats.map { stat in
            var updated = stat
            updated.percentage = total > 0 ? (stat.amount / total) * 100 : 0
            return updated
        }
    }
    
    private func calculateChartData() {
        let transactions = transactionViewModel.getTransactions(for: selectedPeriod)
        let calendar = Calendar.current
        var dailyData: [Date: (income: Double, expense: Double)] = [:]
        
        for transaction in transactions {
            guard let date = transaction.date else { continue }
            let dayStart = calendar.startOfDay(for: date)
            
            if var existing = dailyData[dayStart] {
                if transaction.transactionType == .income {
                    existing.income += transaction.amount
                } else {
                    existing.expense += transaction.amount
                }
                dailyData[dayStart] = existing
            } else {
                if transaction.transactionType == .income {
                    dailyData[dayStart] = (income: transaction.amount, expense: 0)
                } else {
                    dailyData[dayStart] = (income: 0, expense: transaction.amount)
                }
            }
        }
        
        chartData = dailyData.map { date, amounts in
            ChartDataPoint(date: date, income: amounts.income, expense: amounts.expense)
        }
        .sorted { $0.date < $1.date }
    }
    
    func exportToCSV() -> String {
        let transactions = transactionViewModel.getTransactions(for: selectedPeriod)
        var csv = "Date,Type,Category,Amount,Note\n"
        
        for transaction in transactions {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = transaction.date.map { dateFormatter.string(from: $0) } ?? ""
            let type = transaction.transactionType?.rawValue ?? ""
            let category = transaction.category?.name ?? ""
            let amount = String(transaction.amount)
            let note = transaction.note ?? ""
            
            csv += "\(dateString),\(type),\(category),\(amount),\(note)\n"
        }
        
        return csv
    }
}

struct CategoryStat: Identifiable {
    let id = UUID()
    let category: CategoryModel
    let amount: Double
    var percentage: Double
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let income: Double
    let expense: Double
}

