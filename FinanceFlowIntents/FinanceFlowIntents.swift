//
//  FinanceFlowIntents.swift
//  FinanceFlowIntents
//
//  Created by Rafael Mukhametov on 26.11.2025.
//

import AppIntents

// MARK: - Add Transaction Intent
// Примечание: App Shortcuts не поддерживают параметры типа Double напрямую в фразах
// Для добавления транзакций через Siri лучше открывать приложение
struct AddTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Transaction"
    static var description = IntentDescription("Add a new transaction to FinanceFlow")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // Открывает приложение для добавления транзакции
        return .result()
    }
}

enum TransactionTypeIntent: String, AppEnum {
    case income
    case expense
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Transaction Type"
    
    static var caseDisplayRepresentations: [TransactionTypeIntent: DisplayRepresentation] = [
        .income: "Income",
        .expense: "Expense"
    ]
}

// MARK: - View Balance Intent
struct ViewBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "View Balance"
    static var description = IntentDescription("View your total balance in FinanceFlow")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // Открывает приложение на главном экране
        return .result()
    }
}

// MARK: - Quick Add Expense Intent
// Примечание: App Shortcuts не поддерживают параметры типа Double в фразах
// Для быстрого добавления расходов лучше открывать приложение
struct QuickAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Add Expense"
    static var description = IntentDescription("Quickly add an expense transaction")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // Открывает приложение для быстрого добавления расхода
        return .result()
    }
}

// MARK: - Get Balance Intent
struct GetBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Balance"
    static var description = IntentDescription("Get your current balance")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Получаем баланс из App Group
        if let userDefaults = UserDefaults(suiteName: "group.com.financeflow.app"),
           let balance = userDefaults.string(forKey: "cachedBalance") {
            return .result(value: balance)
        }
        
        return .result(value: "Balance not available")
    }
}

// MARK: - App Shortcuts Provider
struct FinanceFlowShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ViewBalanceIntent(),
            phrases: [
                "Show balance in \(.applicationName)",
                "What's my balance in \(.applicationName)",
                "Check balance in \(.applicationName)",
                "View balance in \(.applicationName)"
            ],
            shortTitle: "View Balance",
            systemImageName: "dollarsign.circle"
        )
        
        AppShortcut(
            intent: GetBalanceIntent(),
            phrases: [
                "What's my balance in \(.applicationName)",
                "How much do I have in \(.applicationName)",
                "Check my balance in \(.applicationName)"
            ],
            shortTitle: "Get Balance",
            systemImageName: "dollarsign.circle.fill"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor = .blue
}
