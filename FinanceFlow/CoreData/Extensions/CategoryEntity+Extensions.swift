//
//  CategoryEntity+Extensions.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI

extension CategoryEntity {
    var categoryModel: CategoryModel {
        CategoryModel(
            id: id ?? UUID(),
            name: name ?? "",
            icon: icon ?? "questionmark.circle",
            color: Color.fromHex(colorHex ?? "#000000"),
            isDefault: isDefault,
            transactionType: TransactionType(rawValue: transactionType ?? "expense") ?? .expense
        )
    }
}

