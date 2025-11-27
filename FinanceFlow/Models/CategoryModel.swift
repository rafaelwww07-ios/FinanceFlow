//
//  CategoryModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import SwiftUI

struct CategoryModel: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: Color
    var isDefault: Bool
    var transactionType: TransactionType
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color, isDefault: Bool = false, transactionType: TransactionType) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.isDefault = isDefault
        self.transactionType = transactionType
    }
    
    static let defaultCategories: [CategoryModel] = [
        // Income categories
        CategoryModel(name: "Salary", icon: "dollarsign.circle.fill", color: .green, isDefault: true, transactionType: .income),
        CategoryModel(name: "Freelance", icon: "briefcase.fill", color: .blue, isDefault: true, transactionType: .income),
        CategoryModel(name: "Investment", icon: "chart.line.uptrend.xyaxis", color: .purple, isDefault: true, transactionType: .income),
        CategoryModel(name: "Gift", icon: "gift.fill", color: .pink, isDefault: true, transactionType: .income),
        CategoryModel(name: "Other Income", icon: "plus.circle.fill", color: .gray, isDefault: true, transactionType: .income),
        
        // Expense categories
        CategoryModel(name: "Food", icon: "fork.knife", color: .orange, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Transport", icon: "car.fill", color: .blue, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Entertainment", icon: "tv.fill", color: .purple, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Shopping", icon: "bag.fill", color: .pink, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Bills", icon: "doc.text.fill", color: .red, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Health", icon: "heart.fill", color: .red, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Education", icon: "book.fill", color: .indigo, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Travel", icon: "airplane", color: .cyan, isDefault: true, transactionType: .expense),
        CategoryModel(name: "Other Expense", icon: "minus.circle.fill", color: .gray, isDefault: true, transactionType: .expense)
    ]
}



