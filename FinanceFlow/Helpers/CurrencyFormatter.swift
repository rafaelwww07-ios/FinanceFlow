//
//  CurrencyFormatter.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation

class CurrencyFormatter {
    static func format(_ amount: Double, currencyCode: String = "USD", maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}



