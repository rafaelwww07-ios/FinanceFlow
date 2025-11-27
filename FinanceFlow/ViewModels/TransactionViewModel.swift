//
//  TransactionViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class TransactionViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var transactions: [TransactionEntity] = []
    @Published var filteredTransactions: [TransactionEntity] = []
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var selectedCategoryFilter: CategoryEntity?
    @Published var selectedTypeFilter: TransactionType?
    @Published var dateRangeFilter: ClosedRange<Date>?
    
    // Balance calculations
    var totalBalance: Double {
        transactions.reduce(0) { total, transaction in
            if transaction.transactionType == .income {
                return total + transaction.amount
            } else {
                return total - transaction.amount
            }
        }
    }
    
    var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return transactions
            .filter { transaction in
                guard let date = transaction.date,
                      transaction.transactionType == .income else { return false }
                return date >= startOfMonth
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    var monthlyExpense: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return transactions
            .filter { transaction in
                guard let date = transaction.date,
                      transaction.transactionType == .expense else { return false }
                return date >= startOfMonth
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    init() {
        fetchTransactions()
        applyFilters()
        processPendingTransactionsFromSiri()
    }
    
    // Обработка транзакций из Siri Shortcuts (публичный метод для вызова из View)
    func processPendingTransactionsFromSiri() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.financeflow.app"),
              let pendingTransactions = userDefaults.array(forKey: "pendingTransactions") as? [[String: Any]],
              !pendingTransactions.isEmpty else {
            return
        }
        
        for transactionData in pendingTransactions {
            guard let amount = transactionData["amount"] as? Double,
                  let typeString = transactionData["type"] as? String,
                  let type = TransactionType(rawValue: typeString),
                  let dateInterval = transactionData["date"] as? TimeInterval else {
                continue
            }
            
            let categoryName = transactionData["category"] as? String
            let note = transactionData["note"] as? String
            
            // Находим категорию
            let categoryViewModel = CategoryViewModel()
            let category = categoryViewModel.getCategories(for: type).first { category in
                if let categoryName = categoryName, !categoryName.isEmpty {
                    return category.name == categoryName
                }
                return true
            } ?? categoryViewModel.getCategories(for: type).first
            
            guard let category = category else { continue }
            
            // Добавляем транзакцию
            addTransaction(
                amount: amount,
                type: type,
                category: category,
                date: Date(timeIntervalSince1970: dateInterval),
                note: note?.isEmpty == false ? note : nil
            )
        }
        
        // Очищаем обработанные транзакции
        userDefaults.removeObject(forKey: "pendingTransactions")
        userDefaults.synchronize()
        
        // Обновляем кэш баланса для виджетов
        updateBalanceCache()
    }
    
    // Обновление кэша баланса для виджетов и Siri
    private func updateBalanceCache() {
        let balance = self.totalBalance
        let currencyCode = UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        
        if let userDefaults = UserDefaults(suiteName: "group.com.financeflow.app") {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            let balanceString = formatter.string(from: NSNumber(value: balance)) ?? "$0"
            userDefaults.set(balanceString, forKey: "cachedBalance")
            userDefaults.synchronize()
        }
    }
    
    func fetchTransactions() {
        isLoading = true
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            transactions = try viewContext.fetch(request)
            applyFilters()
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
        isLoading = false
    }
    
    func applyFilters() {
        var filtered = transactions
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                let noteMatch = transaction.note?.localizedCaseInsensitiveContains(searchText) ?? false
                let categoryMatch = transaction.category?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                return noteMatch || categoryMatch
            }
        }
        
        // Category filter
        if let category = selectedCategoryFilter {
            filtered = filtered.filter { $0.category?.id == category.id }
        }
        
        // Type filter
        if let type = selectedTypeFilter {
            filtered = filtered.filter { $0.transactionType == type }
        }
        
        // Date range filter
        if let dateRange = dateRangeFilter {
            filtered = filtered.filter { transaction in
                guard let date = transaction.date else { return false }
                return dateRange.contains(date)
            }
        }
        
        filteredTransactions = filtered
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategoryFilter = nil
        selectedTypeFilter = nil
        dateRangeFilter = nil
        applyFilters()
    }
    
    // Обновление кэша после добавления транзакции
    private func refreshBalanceCache() {
        updateBalanceCache()
    }
    
    func addTransaction(
        amount: Double,
        type: TransactionType,
        category: CategoryEntity,
        date: Date,
        note: String?,
        isRecurring: Bool = false,
        recurringPattern: RecurringPattern? = nil,
        account: AccountEntity? = nil,
        tags: [TagEntity] = []
    ) {
        let transaction = TransactionEntity(context: viewContext)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.type = type.rawValue
        transaction.category = category
        transaction.date = date
        transaction.note = note
        transaction.isRecurring = isRecurring
        transaction.recurringPattern = recurringPattern?.rawValue
        transaction.account = account
        if !tags.isEmpty {
            transaction.tags = NSSet(array: tags)
        }
        
        persistenceController.save()
        fetchTransactions()
        applyFilters()
        refreshBalanceCache()
    }
    
    func updateTransaction(
        _ transaction: TransactionEntity,
        amount: Double,
        type: TransactionType,
        category: CategoryEntity,
        date: Date,
        note: String?
    ) {
        transaction.amount = amount
        transaction.type = type.rawValue
        transaction.category = category
        transaction.date = date
        transaction.note = note
        
        persistenceController.save()
        fetchTransactions()
        applyFilters()
        refreshBalanceCache()
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        viewContext.delete(transaction)
        persistenceController.save()
        fetchTransactions()
        applyFilters()
        refreshBalanceCache()
    }
    
    func saveContext() {
        persistenceController.save()
        fetchTransactions()
        applyFilters()
        refreshBalanceCache()
    }
    
    func getTransactions(for period: StatisticsPeriod) -> [TransactionEntity] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        case .all:
            return transactions
        }
        
        return transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= startDate
        }
    }
}

enum StatisticsPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"
}

