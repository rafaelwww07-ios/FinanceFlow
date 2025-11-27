//
//  TransactionEntity+Extensions.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI

extension TransactionEntity {
    var transactionType: TransactionType? {
        get {
            guard let typeString = type else { return nil }
            return TransactionType(rawValue: typeString)
        }
        set {
            type = newValue?.rawValue
        }
    }
    
    var categoryModel: CategoryModel? {
        guard let category = category else { return nil }
        return CategoryModel(
            id: category.id ?? UUID(),
            name: category.name ?? "",
            icon: category.icon ?? "questionmark.circle",
            color: Color.fromHex(category.colorHex ?? "#000000"),
            isDefault: category.isDefault,
            transactionType: TransactionType(rawValue: category.transactionType ?? "expense") ?? .expense
        )
    }
}

