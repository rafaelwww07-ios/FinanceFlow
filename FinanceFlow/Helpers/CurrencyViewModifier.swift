//
//  CurrencyViewModifier.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

extension View {
    func formatCurrency(_ amount: Double, currencyCode: String) -> String {
        return CurrencyFormatter.format(amount, currencyCode: currencyCode)
    }
}



