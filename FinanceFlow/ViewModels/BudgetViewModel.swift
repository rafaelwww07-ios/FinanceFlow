//
//  BudgetViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class BudgetViewModel: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var budgets: [BudgetEntity] = []
    @Published var isLoading = false
    
    private let transactionViewModel: TransactionViewModel
    
    init(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
        fetchBudgets()
    }
    
    func fetchBudgets() {
        isLoading = true
        let request: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BudgetEntity.amount, ascending: false)]
        
        do {
            budgets = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch budgets: \(error)")
        }
        isLoading = false
    }
    
    func addBudget(
        category: CategoryEntity,
        amount: Double,
        period: BudgetPeriod
    ) {
        let budget = BudgetEntity(context: viewContext)
        budget.id = UUID()
        budget.category = category
        budget.amount = amount
        budget.budgetPeriod = period
        
        persistenceController.save()
        fetchBudgets()
    }
    
    func updateBudget(
        _ budget: BudgetEntity,
        amount: Double,
        period: BudgetPeriod
    ) {
        budget.amount = amount
        budget.budgetPeriod = period
        
        persistenceController.save()
        fetchBudgets()
    }
    
    func deleteBudget(_ budget: BudgetEntity) {
        viewContext.delete(budget)
        persistenceController.save()
        fetchBudgets()
    }
    
    func getSpentAmount(for budget: BudgetEntity, period: BudgetPeriod) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch period {
        case .weekly:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .monthly:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        case .yearly:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        }
        
        guard let category = budget.category else { return 0 }
        
        return transactionViewModel.transactions
            .filter { transaction in
                guard let date = transaction.date,
                      transaction.category?.id == category.id,
                      transaction.transactionType == .expense else { return false }
                return date >= startDate
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getRemainingAmount(for budget: BudgetEntity) -> Double {
        let spent = getSpentAmount(for: budget, period: budget.budgetPeriod ?? .monthly)
        return budget.amount - spent
    }
    
    func getProgress(for budget: BudgetEntity) -> Double {
        let spent = getSpentAmount(for: budget, period: budget.budgetPeriod ?? .monthly)
        guard budget.amount > 0 else { return 0 }
        return min(spent / budget.amount, 1.0)
    }
}



