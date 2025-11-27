//
//  BudgetsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct BudgetsView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var budgetViewModel: BudgetViewModel
    @State private var showingAddBudget = false
    @AppStorage("budgetAlertsEnabled") private var budgetAlertsEnabled: Bool = true
    
    init() {
        let transactionVM = TransactionViewModel()
        _transactionViewModel = StateObject(wrappedValue: transactionVM)
        _budgetViewModel = StateObject(wrappedValue: BudgetViewModel(transactionViewModel: transactionVM))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if budgetViewModel.budgets.isEmpty {
                    EmptyBudgetsView()
                } else {
                    ForEach(budgetViewModel.budgets) { budget in
                        BudgetRowView(
                            budget: budget,
                            budgetViewModel: budgetViewModel
                        )
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            budgetViewModel.deleteBudget(budgetViewModel.budgets[index])
                        }
                    }
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBudget = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(
                    budgetViewModel: budgetViewModel,
                    categoryViewModel: categoryViewModel
                )
            }
            .onAppear {
                if budgetAlertsEnabled {
                    NotificationService.shared.checkBudgetsAndNotify(budgetViewModel: budgetViewModel, currencyCode: currencyCode)
                }
            }
            .onChange(of: budgetViewModel.budgets) { _, _ in
                if budgetAlertsEnabled {
                    NotificationService.shared.checkBudgetsAndNotify(budgetViewModel: budgetViewModel, currencyCode: currencyCode)
                }
            }
        }
    }
}

struct BudgetRowView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let budget: BudgetEntity
    @ObservedObject var budgetViewModel: BudgetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let category = budget.category {
                    ZStack {
                        Circle()
                            .fill(Color.fromHex(category.colorHex ?? "#000000").opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: category.icon ?? "questionmark.circle")
                            .foregroundColor(Color.fromHex(category.colorHex ?? "#000000"))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category?.name ?? "Unknown")
                        .font(.headline)
                    
                    Text(budget.budgetPeriod?.displayName ?? "Monthly")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(budget.amount))
                        .font(.headline)
                    
                    let spent = budgetViewModel.getSpentAmount(for: budget, period: budget.budgetPeriod ?? .monthly)
                    let remaining = budgetViewModel.getRemainingAmount(for: budget)
                    
                    Text("Spent: \(formatCurrency(spent))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Remaining: \(formatCurrency(remaining))")
                        .font(.caption)
                        .foregroundColor(remaining >= 0 ? .green : .red)
                }
            }
            
            // Progress bar
            let progress = budgetViewModel.getProgress(for: budget)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(progress >= 1.0 ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyFormatter.format(amount, currencyCode: currencyCode)
    }
}

struct EmptyBudgetsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No budgets set")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap + to create your first budget")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    @State private var selectedCategory: CategoryEntity?
    @State private var amount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    if let selectedCategory = selectedCategory {
                        CategoryPickerRow(category: selectedCategory)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select category").tag(nil as CategoryEntity?)
                        ForEach(categoryViewModel.getCategories(for: .expense)) { category in
                            Text(category.name ?? "Unknown").tag(category as CategoryEntity?)
                        }
                    }
                }
                
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Period") {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if selectedCategory == nil {
                    selectedCategory = categoryViewModel.getCategories(for: .expense).first
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let amountValue = Double(amount),
              amountValue > 0,
              selectedCategory != nil else {
            return false
        }
        return true
    }
    
    private func saveBudget() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        budgetViewModel.addBudget(
            category: category,
            amount: amountValue,
            period: selectedPeriod
        )
        
        dismiss()
    }
}

#Preview {
    BudgetsView()
}

