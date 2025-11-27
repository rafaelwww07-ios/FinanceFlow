//
//  SocialView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct SocialView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    
    var body: some View {
        NavigationStack {
            List {
                Section("Shared Budgets") {
                    Text("Create and manage budgets with family or friends")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button {
                        // Create shared budget
                    } label: {
                        HStack {
                            Image(systemName: "person.2.fill")
                            Text("Create Shared Budget")
                        }
                    }
                }
                
                Section("Compare Spending") {
                    Text("Compare your spending patterns anonymously with others")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    NavigationLink {
                        ComparisonView(transactionViewModel: transactionViewModel)
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar.xaxis")
                            Text("View Comparison")
                        }
                    }
                }
                
                Section("Coming Soon") {
                    Text("• Family budgets with real-time sync")
                    Text("• Anonymous spending comparisons")
                    Text("• Savings challenges with friends")
                    Text("• Group expense splitting")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .navigationTitle("Social")
        }
    }
}

struct ComparisonView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    
    var body: some View {
        List {
            Section("Your Spending") {
                let monthlyExpense = transactionViewModel.monthlyExpense
                StatRow(label: "This Month", value: CurrencyFormatter.format(monthlyExpense, currencyCode: currencyCode))
            }
            
            Section("Average (Anonymous)") {
                // В реальном приложении это будет загружаться с сервера
                StatRow(label: "Average Monthly Spending", value: CurrencyFormatter.format(2500, currencyCode: currencyCode))
                StatRow(label: "Your Rank", value: "Top 30%")
            }
            
            Section("Info") {
                Text("Comparisons are based on anonymous, aggregated data from other FinanceFlow users.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Spending Comparison")
    }
}



