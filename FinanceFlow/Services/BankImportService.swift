//
//  BankImportService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation

class BankImportService {
    static let shared = BankImportService()
    
    private init() {}
    
    // MARK: - Supported Banks
    enum SupportedBank: String, CaseIterable {
        case sberbank = "Sberbank"
        case alfaBank = "Alfa Bank"
        case tinkoff = "Tinkoff"
        case vtb = "VTB"
        case manual = "Manual Import"
        
        var icon: String {
            switch self {
            case .sberbank: return "building.columns.fill"
            case .alfaBank: return "creditcard.fill"
            case .tinkoff: return "banknote.fill"
            case .vtb: return "building.2.fill"
            case .manual: return "doc.text.fill"
            }
        }
    }
    
    // MARK: - Import Methods
    func importFromCSV(data: Data, bank: SupportedBank) -> [ImportedTransaction] {
        guard let csvString = String(data: data, encoding: .utf8) else {
            return []
        }
        
        let lines = csvString.components(separatedBy: .newlines)
        var transactions: [ImportedTransaction] = []
        
        // Пропускаем заголовок
        for line in lines.dropFirst() {
            if line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            if components.count >= 3 {
                let dateString = components[0].trimmingCharacters(in: .whitespaces)
                let amountString = components[1].trimmingCharacters(in: .whitespaces)
                let description = components[2].trimmingCharacters(in: .whitespaces)
                
                if let amount = Double(amountString),
                   let date = parseDate(dateString) {
                    let transaction = ImportedTransaction(
                        date: date,
                        amount: abs(amount),
                        type: amount >= 0 ? .income : .expense,
                        description: description,
                        category: nil
                    )
                    transactions.append(transaction)
                }
            }
        }
        
        return transactions
    }
    
    func importFromOFX(data: Data) -> [ImportedTransaction] {
        // OFX (Open Financial Exchange) формат
        // Базовая структура для будущей реализации
        return []
    }
    
    func importFromQIF(data: Data) -> [ImportedTransaction] {
        // QIF (Quicken Interchange Format) формат
        // Базовая структура для будущей реализации
        return []
    }
    
    // MARK: - Auto-categorization
    func categorizeTransaction(_ transaction: ImportedTransaction) -> String? {
        return AutoCategorizationService.shared.suggestCategory(
            for: transaction.description,
            transactionType: transaction.type
        )
    }
    
    // MARK: - Helpers
    private func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            DateFormatter.iso8601,
            DateFormatter.shortDate,
            DateFormatter.mediumDate,
            DateFormatter.longDate
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
}

struct ImportedTransaction {
    let date: Date
    let amount: Double
    let type: TransactionType
    let description: String
    var category: String?
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
}



