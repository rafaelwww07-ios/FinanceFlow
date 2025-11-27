//
//  BudgetEntity+Extensions.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData

extension BudgetEntity {
    var budgetPeriod: BudgetPeriod? {
        get {
            guard let periodString = period else { return nil }
            return BudgetPeriod(rawValue: periodString)
        }
        set {
            period = newValue?.rawValue
        }
    }
}



