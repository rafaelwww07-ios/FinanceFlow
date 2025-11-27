//
//  ExportService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import UIKit
import PDFKit

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    // MARK: - Excel Export (CSV format, можно расширить до XLSX)
    func exportToCSV(transactions: [TransactionEntity], currencyCode: String) -> String {
        var csv = "Date,Type,Category,Amount,Note,Account,Tags\n"
        
        for transaction in transactions.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) }) {
            let date = transaction.date?.formatted(date: .numeric, time: .omitted) ?? ""
            let type = transaction.transactionType?.rawValue ?? ""
            let category = transaction.category?.name ?? ""
            let amount = CurrencyFormatter.format(transaction.amount, currencyCode: currencyCode)
            let note = transaction.note ?? ""
            let account = transaction.account?.name ?? ""
            let tags = (transaction.tags as? Set<TagEntity>)?.map { $0.name ?? "" }.joined(separator: "; ") ?? ""
            
            csv += "\(date),\(type),\(category),\(amount),\(note),\(account),\(tags)\n"
        }
        
        return csv
    }
    
    // MARK: - Excel Export (XLSX) - используем библиотеку или создаем простой формат
    func exportToExcel(transactions: [TransactionEntity], currencyCode: String) -> Data? {
        // Для полноценного XLSX нужна библиотека, здесь используем CSV как альтернативу
        let csv = exportToCSV(transactions: transactions, currencyCode: currencyCode)
        return csv.data(using: .utf8)
    }
    
    // MARK: - Yearly Report
    func generateYearlyReport(transactions: [TransactionEntity], year: Int, currencyCode: String) -> String {
        let calendar = Calendar.current
        let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let yearEnd = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        
        let yearTransactions = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= yearStart && date <= yearEnd
        }
        
        let totalIncome = yearTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
        
        let totalExpense = yearTransactions
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
        
        var report = "YEARLY FINANCIAL REPORT \(year)\n"
        report += "================================\n\n"
        report += "Total Income: \(CurrencyFormatter.format(totalIncome, currencyCode: currencyCode))\n"
        report += "Total Expense: \(CurrencyFormatter.format(totalExpense, currencyCode: currencyCode))\n"
        report += "Net Balance: \(CurrencyFormatter.format(totalIncome - totalExpense, currencyCode: currencyCode))\n\n"
        
        // By category
        var categoryTotals: [String: Double] = [:]
        for transaction in yearTransactions.filter({ $0.transactionType == .expense }) {
            let categoryName = transaction.category?.name ?? "Unknown"
            categoryTotals[categoryName, default: 0] += transaction.amount
        }
        
        report += "EXPENSES BY CATEGORY:\n"
        report += "--------------------\n"
        for (category, amount) in categoryTotals.sorted(by: { $0.value > $1.value }) {
            report += "\(category): \(CurrencyFormatter.format(amount, currencyCode: currencyCode))\n"
        }
        
        return report
    }
    
    // MARK: - Tax Report
    func generateTaxReport(transactions: [TransactionEntity], year: Int, currencyCode: String) -> String {
        let calendar = Calendar.current
        let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let yearEnd = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        
        let yearTransactions = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= yearStart && date <= yearEnd
        }
        
        // Категории, которые могут быть налоговыми вычетами
        let deductibleCategories = ["Charity", "Medical", "Education", "Business"]
        
        var report = "TAX REPORT \(year)\n"
        report += "===================\n\n"
        
        let totalIncome = yearTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
        
        report += "TOTAL INCOME:\n"
        report += "\(CurrencyFormatter.format(totalIncome, currencyCode: currencyCode))\n\n"
        
        report += "POTENTIAL DEDUCTIONS:\n"
        report += "---------------------\n"
        
        var deductibleTotal: Double = 0
        for category in deductibleCategories {
            let categoryTotal = yearTransactions
                .filter { $0.transactionType == .expense && $0.category?.name == category }
                .reduce(0) { $0 + $1.amount }
            
            if categoryTotal > 0 {
                report += "\(category): \(CurrencyFormatter.format(categoryTotal, currencyCode: currencyCode))\n"
                deductibleTotal += categoryTotal
            }
        }
        
        report += "\nTotal Deductions: \(CurrencyFormatter.format(deductibleTotal, currencyCode: currencyCode))\n"
        report += "Taxable Income: \(CurrencyFormatter.format(totalIncome - deductibleTotal, currencyCode: currencyCode))\n"
        
        return report
    }
    
    // MARK: - PDF Export
    func generatePDF(transactions: [TransactionEntity], currencyCode: String) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "FinanceFlow",
            kCGPDFContextAuthor: "FinanceFlow App",
            kCGPDFContextTitle: "Transaction Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            let title = "Transaction Report"
            title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ])
            
            yPosition += 40
            
            for transaction in transactions.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) }) {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
                
                let date = transaction.date?.formatted(date: .numeric, time: .omitted) ?? ""
                let category = transaction.category?.name ?? "Unknown"
                let amount = CurrencyFormatter.format(transaction.amount, currencyCode: currencyCode)
                let type = transaction.transactionType?.rawValue ?? ""
                
                let text = "\(date) - \(category) - \(type): \(amount)"
                text.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 12)
                ])
                
                yPosition += 20
            }
        }
        
        return data
    }
}



