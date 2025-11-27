//
//  NotificationService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleBudgetAlert(categoryName: String, spent: Double, budget: Double, period: String, currencyCode: String = "USD") {
        let content = UNMutableNotificationContent()
        content.title = "Budget Alert"
        content.body = "You've spent \(CurrencyFormatter.format(spent, currencyCode: currencyCode)) of \(CurrencyFormatter.format(budget, currencyCode: currencyCode)) for \(categoryName) (\(period))"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget_\(categoryName)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleBudgetWarning(categoryName: String, percentage: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Budget Warning"
        content.body = "You've used \(Int(percentage * 100))% of your \(categoryName) budget"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget_warning_\(categoryName)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func checkBudgetsAndNotify(budgetViewModel: BudgetViewModel, currencyCode: String = "USD") {
        for budget in budgetViewModel.budgets {
            let progress = budgetViewModel.getProgress(for: budget)
            let remaining = budgetViewModel.getRemainingAmount(for: budget)
            
            // Alert at 80%
            if progress >= 0.8 && progress < 0.9 {
                if let categoryName = budget.category?.name {
                    scheduleBudgetWarning(categoryName: categoryName, percentage: progress)
                }
            }
            
            // Alert when exceeded
            if remaining < 0 {
                if let categoryName = budget.category?.name {
                    let spent = budgetViewModel.getSpentAmount(for: budget, period: budget.budgetPeriod ?? .monthly)
                    scheduleBudgetAlert(
                        categoryName: categoryName,
                        spent: spent,
                        budget: budget.amount,
                        period: budget.budgetPeriod?.displayName ?? "Monthly",
                        currencyCode: currencyCode
                    )
                }
            }
        }
    }
    
}

