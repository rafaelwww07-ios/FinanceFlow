//
//  EnhancedNotificationService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import UserNotifications

class EnhancedNotificationService {
    static let shared = EnhancedNotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Recurring Payment Reminders
    func scheduleRecurringPaymentReminder(
        transactionName: String,
        amount: Double,
        date: Date,
        recurringPattern: RecurringPattern,
        currencyCode: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder"
        content.body = "Don't forget: \(transactionName) - \(CurrencyFormatter.format(amount, currencyCode: currencyCode))"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        switch recurringPattern {
        case .daily:
            dateComponents.day = nil
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            scheduleNotification(content: content, trigger: trigger, identifier: "recurring_\(transactionName)")
        case .weekly:
            dateComponents.weekday = calendar.component(.weekday, from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            scheduleNotification(content: content, trigger: trigger, identifier: "recurring_\(transactionName)")
        case .monthly:
            dateComponents.day = calendar.component(.day, from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            scheduleNotification(content: content, trigger: trigger, identifier: "recurring_\(transactionName)")
        case .yearly:
            dateComponents.month = calendar.component(.month, from: date)
            dateComponents.day = calendar.component(.day, from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            scheduleNotification(content: content, trigger: trigger, identifier: "recurring_\(transactionName)")
        }
    }
    
    // MARK: - Large Expense Alerts
    func checkForLargeExpenses(transactions: [TransactionEntity], threshold: Double, currencyCode: String) {
        let today = Date()
        let calendar = Calendar.current
        let todayTransactions = transactions.filter { transaction in
            guard let date = transaction.date,
                  transaction.transactionType == .expense else { return false }
            return calendar.isDate(date, inSameDayAs: today)
        }
        
        for transaction in todayTransactions {
            if transaction.amount >= threshold {
                let content = UNMutableNotificationContent()
                content.title = "Large Expense Alert"
                content.body = "You spent \(CurrencyFormatter.format(transaction.amount, currencyCode: currencyCode)) on \(transaction.category?.name ?? "Unknown")"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                scheduleNotification(
                    content: content,
                    trigger: trigger,
                    identifier: "large_expense_\(transaction.id?.uuidString ?? UUID().uuidString)"
                )
            }
        }
    }
    
    // MARK: - Daily/Weekly Summaries
    func scheduleDailySummary(transactions: [TransactionEntity], currencyCode: String) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Summary"
        
        let calendar = Calendar.current
        let today = Date()
        let todayTransactions = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return calendar.isDate(date, inSameDayAs: today)
        }
        
        let totalExpense = todayTransactions
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
        
        let totalIncome = todayTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
        
        content.body = "Today: Income: \(CurrencyFormatter.format(totalIncome, currencyCode: currencyCode)), Expense: \(CurrencyFormatter.format(totalExpense, currencyCode: currencyCode))"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        scheduleNotification(content: content, trigger: trigger, identifier: "daily_summary")
    }
    
    func scheduleWeeklySummary(transactions: [TransactionEntity], currencyCode: String) {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Summary"
        
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        let weekTransactions = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= weekStart
        }
        
        let totalExpense = weekTransactions
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
        
        let totalIncome = weekTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
        
        content.body = "This week: Income: \(CurrencyFormatter.format(totalIncome, currencyCode: currencyCode)), Expense: \(CurrencyFormatter.format(totalExpense, currencyCode: currencyCode))"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        scheduleNotification(content: content, trigger: trigger, identifier: "weekly_summary")
    }
    
    private func scheduleNotification(content: UNMutableNotificationContent, trigger: UNNotificationTrigger, identifier: String) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}



