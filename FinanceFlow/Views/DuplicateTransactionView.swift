//
//  DuplicateTransactionView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct DuplicateTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @ObservedObject var accountViewModel: AccountViewModel
    @ObservedObject var tagViewModel: TagViewModel
    
    let transaction: TransactionEntity
    
    @State private var amount: String = ""
    @State private var selectedCategory: CategoryEntity?
    @State private var selectedType: TransactionType = .expense
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var selectedAccount: AccountEntity?
    @State private var selectedTags: Set<TagEntity> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categoryViewModel.getCategories(for: selectedType)) { category in
                            Text(category.name ?? "Unknown").tag(category as CategoryEntity?)
                        }
                    }
                }
                
                Section("Date & Time") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Note") {
                    TextField("Optional note", text: $note)
                }
                
                Section("Account") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("None").tag(nil as AccountEntity?)
                        ForEach(accountViewModel.accounts) { account in
                            Text(account.name ?? "Unknown").tag(account as AccountEntity?)
                        }
                    }
                }
                
                Section("Tags") {
                    if tagViewModel.tags.isEmpty {
                        Text("No tags available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(tagViewModel.tags) { tag in
                            Button {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            } label: {
                                HStack {
                                    Text(tag.name ?? "Unknown")
                                    Spacer()
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Duplicate Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                loadTransactionData()
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
    
    private func loadTransactionData() {
        amount = String(transaction.amount)
        selectedType = transaction.transactionType ?? .expense
        selectedCategory = transaction.category
        date = transaction.date ?? Date()
        note = transaction.note ?? ""
        selectedAccount = transaction.account
        
        if let tags = transaction.tags as? Set<TagEntity> {
            selectedTags = tags
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        transactionViewModel.addTransaction(
            amount: amountValue,
            type: selectedType,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note,
            account: selectedAccount,
            tags: Array(selectedTags)
        )
        
        dismiss()
    }
}



