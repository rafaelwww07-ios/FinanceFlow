//
//  ExcelExportService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation

class ExcelExportService {
    static let shared = ExcelExportService()
    
    private init() {}
    
    // MARK: - Excel Export (XLSX format)
    // Примечание: Для полноценного XLSX нужна библиотека, здесь создаем структуру
    // В реальном приложении можно использовать библиотеку вроде ZippyJSON или создать XML структуру
    
    func exportToXLSX(transactions: [TransactionEntity], currencyCode: String) -> Data? {
        // Создаем CSV как временное решение (CSV можно открыть в Excel)
        // Для настоящего XLSX нужна библиотека или ручное создание ZIP архива с XML файлами
        
        var csv = "Date,Type,Category,Amount,Note,Account,Tags\n"
        
        for transaction in transactions.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) }) {
            let date = transaction.date?.formatted(date: .numeric, time: .omitted) ?? ""
            let type = transaction.transactionType?.rawValue ?? ""
            let category = transaction.category?.name ?? ""
            let amount = String(transaction.amount)
            let note = transaction.note?.replacingOccurrences(of: ",", with: ";") ?? ""
            let account = transaction.account?.name?.replacingOccurrences(of: ",", with: ";") ?? ""
            let tags = (transaction.tags as? Set<TagEntity>)?.map { $0.name?.replacingOccurrences(of: ",", with: ";") ?? "" }.joined(separator: "; ") ?? ""
            
            csv += "\(date),\(type),\(category),\(amount),\(note),\(account),\(tags)\n"
        }
        
        return csv.data(using: .utf8)
    }
    
    // MARK: - Advanced Excel Export with Formatting
    func exportToFormattedExcel(transactions: [TransactionEntity], currencyCode: String) -> Data? {
        // Для форматированного Excel нужна библиотека
        // Здесь базовая структура
        return exportToXLSX(transactions: transactions, currencyCode: currencyCode)
    }
    
    // MARK: - Multiple Sheets Export
    func exportToMultiSheetExcel(
        transactions: [TransactionEntity],
        budgets: [BudgetEntity],
        goals: [GoalEntity],
        currencyCode: String
    ) -> Data? {
        // Экспорт в Excel с несколькими листами
        // Базовая структура
        return exportToXLSX(transactions: transactions, currencyCode: currencyCode)
    }
}



