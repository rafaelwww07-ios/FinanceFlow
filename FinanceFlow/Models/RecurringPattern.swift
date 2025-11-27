//
//  RecurringPattern.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation

enum RecurringPattern: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
    
    var nextDate: (Date) -> Date {
        switch self {
        case .daily:
            return { Calendar.current.date(byAdding: .day, value: 1, to: $0) ?? $0 }
        case .weekly:
            return { Calendar.current.date(byAdding: .weekOfYear, value: 1, to: $0) ?? $0 }
        case .monthly:
            return { Calendar.current.date(byAdding: .month, value: 1, to: $0) ?? $0 }
        case .yearly:
            return { Calendar.current.date(byAdding: .year, value: 1, to: $0) ?? $0 }
        }
    }
}



