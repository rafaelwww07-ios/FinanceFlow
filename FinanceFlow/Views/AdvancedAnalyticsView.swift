//
//  AdvancedAnalyticsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import Charts

struct AdvancedAnalyticsView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    private let aiService = AIAnalyticsService.shared
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    
    @State private var selectedPeriod: StatisticsPeriod = .month
    
    var insights: [String] {
        aiService.generateSpendingInsights(transactions: transactionViewModel.transactions)
    }
    
    var recommendations: [String] {
        let budgetViewModel = BudgetViewModel(transactionViewModel: transactionViewModel)
        return aiService.generateRecommendations(
            transactions: transactionViewModel.transactions,
            budgets: budgetViewModel.budgets,
            transactionViewModel: transactionViewModel
        )
    }
    
    var predictedSpending: Double {
        aiService.predictNextMonthSpending(transactions: transactionViewModel.transactions)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Insights")
                            .font(.headline)
                        
                        ForEach(insights, id: \.self) { insight in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                
                                Text(insight)
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    // Recommendations
                    if !recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommendations")
                                .font(.headline)
                            
                            ForEach(recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                    
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    }
                    
                    // Spending Prediction
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending Prediction")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Next Month")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(CurrencyFormatter.format(predictedSpending, currencyCode: currencyCode))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Based on your spending patterns")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Advanced Analytics")
        }
    }
}


