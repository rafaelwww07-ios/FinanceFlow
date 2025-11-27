//
//  AutoCategorizationService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation

class AutoCategorizationService {
    static let shared = AutoCategorizationService()
    
    // Словарь ключевых слов для автоматической категоризации
    private let categoryKeywords: [String: [String]] = [
        "Food": ["restaurant", "cafe", "food", "grocery", "supermarket", "meal", "lunch", "dinner", "breakfast", "pizza", "burger", "coffee", "starbucks", "mcdonald"],
        "Transport": ["uber", "taxi", "gas", "fuel", "parking", "metro", "bus", "train", "flight", "airport", "car", "transport"],
        "Shopping": ["amazon", "store", "shop", "mall", "clothing", "clothes", "shoes", "online", "purchase"],
        "Entertainment": ["movie", "cinema", "netflix", "spotify", "game", "concert", "theater", "entertainment"],
        "Bills": ["electricity", "water", "gas bill", "internet", "phone", "utility", "bill", "payment"],
        "Healthcare": ["pharmacy", "doctor", "hospital", "medicine", "medical", "health", "dentist"],
        "Education": ["school", "university", "course", "book", "education", "tuition"],
        "Salary": ["salary", "paycheck", "income", "wage", "payment"],
        "Investment": ["investment", "stock", "dividend", "profit", "return"]
    ]
    
    private init() {}
    
    func suggestCategory(for note: String, transactionType: TransactionType) -> String? {
        let lowercasedNote = note.lowercased()
        
        // Ищем совпадения ключевых слов
        var categoryScores: [String: Int] = [:]
        
        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if lowercasedNote.contains(keyword) {
                    categoryScores[category, default: 0] += 1
                }
            }
        }
        
        // Возвращаем категорию с наибольшим количеством совпадений
        if let bestCategory = categoryScores.max(by: { $0.value < $1.value }) {
            return bestCategory.key
        }
        
        return nil
    }
    
    func learnFromTransaction(note: String, categoryName: String) {
        // Простое обучение: добавляем слова из заметки к ключевым словам категории
        // В реальном приложении можно использовать более сложные алгоритмы ML
        let words = note.lowercased().components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 } // Игнорируем короткие слова
        
        if var existingKeywords = categoryKeywords[categoryName] {
            // Добавляем новые слова (упрощенная версия)
            // В реальном приложении нужно сохранять это в UserDefaults или Core Data
        }
    }
}



