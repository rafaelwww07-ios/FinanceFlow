//
//  ComparisonSectionView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct ComparisonSectionView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @ObservedObject var transactionViewModel: TransactionViewModel
    let currentPeriod: StatisticsPeriod
    @Binding var comparisonPeriod: StatisticsPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Period Comparison")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ComparisonRow(
                    label: "Current Period",
                    period: currentPeriod,
                    amount: getAmount(for: currentPeriod)
                )
                
                Picker("Compare with", selection: $comparisonPeriod) {
                    ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                        if period != currentPeriod {
                            Text(period.rawValue).tag(period)
                        }
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                
                ComparisonRow(
                    label: "Previous Period",
                    period: comparisonPeriod,
                    amount: getAmount(for: comparisonPeriod)
                )
                
                let current = getAmount(for: currentPeriod)
                let previous = getAmount(for: comparisonPeriod)
                let difference = current - previous
                let percentage = previous > 0 ? (difference / previous) * 100 : 0
                
                HStack {
                    Text("Difference:")
                        .font(.headline)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(CurrencyFormatter.format(difference, currencyCode: currencyCode))
                            .font(.headline)
                            .foregroundColor(difference >= 0 ? .green : .red)
                        Text("\(difference >= 0 ? "+" : "")\(String(format: "%.1f", percentage))%")
                            .font(.caption)
                            .foregroundColor(difference >= 0 ? .green : .red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    private func getAmount(for period: StatisticsPeriod) -> Double {
        let transactions = transactionViewModel.getTransactions(for: period)
        let income = transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
        return income - expense
    }
    
}

struct ComparisonRow: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let label: String
    let period: StatisticsPeriod
    let amount: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(period.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(CurrencyFormatter.format(amount, currencyCode: currencyCode))
                .font(.headline)
                .foregroundColor(amount >= 0 ? .green : .red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ComparisonSectionView(
        transactionViewModel: TransactionViewModel(),
        currentPeriod: .month,
        comparisonPeriod: .constant(.week)
    )
    .padding()
}

