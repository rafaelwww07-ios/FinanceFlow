//
//  SearchTransactionRowView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct SearchTransactionRowView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let transaction: TransactionEntity
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            if let category = transaction.category {
                ZStack {
                    Circle()
                        .fill(Color.fromHex(category.colorHex ?? "#000000").opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: category.icon ?? "questionmark.circle")
                        .foregroundColor(Color.fromHex(category.colorHex ?? "#000000"))
                }
            }
            
            // Transaction Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category?.name ?? "Unknown")
                    .font(.headline)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(transaction.date?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(CurrencyFormatter.format(transaction.amount, currencyCode: currencyCode))
                    .font(.headline)
                    .foregroundColor(transaction.transactionType?.color ?? .primary)
                
                Text(transaction.transactionType?.displayName ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}



