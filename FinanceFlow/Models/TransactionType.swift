//
//  TransactionType.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import SwiftUI

enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    
    var displayName: LocalizedStringKey {
        switch self {
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        }
    }
    
    var icon: String {
        switch self {
        case .income:
            return "arrow.up.circle.fill"
        case .expense:
            return "arrow.down.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .income:
            return .green
        case .expense:
            return .red
        }
    }
}

