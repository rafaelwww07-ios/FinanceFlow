//
//  TransactionEntity+Recurring.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData

extension TransactionEntity {
    var recurringPatternType: RecurringPattern? {
        get {
            guard let patternString = recurringPattern else { return nil }
            return RecurringPattern(rawValue: patternString)
        }
        set {
            recurringPattern = newValue?.rawValue
        }
    }
}

