//
//  CoreDataModels.swift
//  FinanceFlowWidget
//
//  Created by Rafael Mukhametov on 26.11.2025.
//

import Foundation
import CoreData

// Временное решение: определяем минимальные типы для виджета
// В реальном приложении эти типы будут доступны после добавления FinanceFlowModel.xcdatamodeld в таргет виджета

extension NSManagedObject {
    // Базовые свойства, которые есть у всех Core Data объектов
}

// Вспомогательная структура для работы с транзакциями в виджете
struct TransactionData {
    let amount: Double
    let type: String // "income" или "expense"
    let date: Date?
}


