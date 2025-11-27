//
//  TodayView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @State private var showingAddTransaction = false
    @State private var showingVoiceInput = false
    @State private var editingTransaction: TransactionEntity?
    @State private var duplicatingTransaction: TransactionEntity?
    @State private var selectedTransactionType: TransactionType = .expense
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card
                    BalanceCardView(
                        totalBalance: transactionViewModel.totalBalance,
                        monthlyIncome: transactionViewModel.monthlyIncome,
                        monthlyExpense: transactionViewModel.monthlyExpense
                    )
                    
                    // Quick Actions
                    QuickActionsView(
                        showingAddTransaction: $showingAddTransaction,
                        selectedType: $selectedTransactionType
                    )
                    
                    // Recent Transactions
                    RecentTransactionsView(
                        transactions: Array(transactionViewModel.filteredTransactions.isEmpty ? transactionViewModel.transactions.prefix(10) : transactionViewModel.filteredTransactions.prefix(10)),
                        onEdit: { transaction in
                            editingTransaction = transaction
                        },
                        onDelete: { transaction in
                            transactionViewModel.deleteTransaction(transaction)
                        },
                        onDuplicate: { transaction in
                            duplicatingTransaction = transaction
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SearchTransactionsView(
                            transactionViewModel: transactionViewModel,
                            categoryViewModel: categoryViewModel
                        )
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingVoiceInput = true
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                    }
                    
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(
                    transactionViewModel: transactionViewModel,
                    categoryViewModel: categoryViewModel,
                    initialType: selectedTransactionType
                )
            }
            .sheet(item: $editingTransaction) { transaction in
                EditTransactionView(
                    transaction: transaction,
                    transactionViewModel: transactionViewModel,
                    categoryViewModel: categoryViewModel
                )
            }
            .sheet(item: $duplicatingTransaction) { transaction in
                DuplicateTransactionView(
                    transactionViewModel: transactionViewModel,
                    categoryViewModel: categoryViewModel,
                    accountViewModel: AccountViewModel(transactionViewModel: transactionViewModel),
                    tagViewModel: TagViewModel(),
                    transaction: transaction
                )
            }
            .sheet(isPresented: $showingVoiceInput) {
                VoiceInputView(
                    transactionViewModel: transactionViewModel,
                    categoryViewModel: categoryViewModel
                )
            }
            .refreshable {
                transactionViewModel.fetchTransactions()
            }
            .onAppear {
                // Обрабатываем транзакции из Siri при открытии экрана
                transactionViewModel.processPendingTransactionsFromSiri()
            }
        }
    }
}

struct BalanceCardView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpense: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(totalBalance))
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(totalBalance >= 0 ? .primary : .red)
            
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(monthlyIncome))
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(monthlyExpense))
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct QuickActionsView: View {
    @Binding var showingAddTransaction: Bool
    @Binding var selectedType: TransactionType
    
    var body: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                type: .income,
                isSelected: selectedType == .income,
                action: {
                    selectedType = .income
                    showingAddTransaction = true
                }
            )
            
            QuickActionButton(
                type: .expense,
                isSelected: selectedType == .expense,
                action: {
                    selectedType = .expense
                    showingAddTransaction = true
                }
            )
        }
    }
}

struct QuickActionButton: View {
    let type: TransactionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                    .font(.title2)
                Text(type.displayName)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(type.color.opacity(isSelected ? 0.2 : 0.1))
            .foregroundColor(type.color)
            .cornerRadius(12)
        }
    }
}

struct RecentTransactionsView: View {
    let transactions: [TransactionEntity]
    let onEdit: (TransactionEntity) -> Void
    let onDelete: (TransactionEntity) -> Void
    let onDuplicate: (TransactionEntity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.headline)
                .padding(.horizontal)
            
            if transactions.isEmpty {
                EmptyTransactionsView()
            } else {
                ForEach(transactions) { transaction in
                    TransactionRowView(
                        transaction: transaction,
                        onEdit: { onEdit(transaction) },
                        onDelete: { onDelete(transaction) },
                        onDuplicate: { onDuplicate(transaction) }
                    )
                }
            }
        }
    }
}

struct TransactionRowView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let transaction: TransactionEntity
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
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
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onDuplicate()
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            .tint(.green)
            
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No transactions yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap + to add your first transaction")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    TodayView()
}

