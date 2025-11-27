//
//  AddTransactionView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import CoreData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    var initialType: TransactionType = .expense
    
    @State private var amount: String = ""
    @State private var selectedType: TransactionType
    @State private var selectedCategory: CategoryEntity?
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isRecurring: Bool = false
    @State private var recurringPattern: RecurringPattern = .monthly
    @State private var selectedAccount: AccountEntity?
    @State private var selectedTags: Set<TagEntity> = []
    @State private var receiptImage: UIImage?
    @State private var showingImagePicker = false
    @StateObject private var accountViewModel: AccountViewModel
    @StateObject private var tagViewModel = TagViewModel()
    
    init(transactionViewModel: TransactionViewModel, categoryViewModel: CategoryViewModel, initialType: TransactionType = .expense) {
        self.transactionViewModel = transactionViewModel
        self.categoryViewModel = categoryViewModel
        self.initialType = initialType
        _selectedType = State(initialValue: initialType)
        let accountVM = AccountViewModel(transactionViewModel: transactionViewModel)
        _accountViewModel = StateObject(wrappedValue: accountVM)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                }
                
                Section("Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    if let selectedCategory = selectedCategory {
                        CategoryPickerRow(category: selectedCategory)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categoryViewModel.getCategories(for: selectedType)) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
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
                        ForEach(accountViewModel.accounts) { account in
                            HStack {
                                Image(systemName: account.icon ?? "creditcard.fill")
                                Text(account.name ?? "Unknown")
                            }
                            .tag(account as AccountEntity?)
                        }
                    }
                }
                
                Section("Tags") {
                    if tagViewModel.tags.isEmpty {
                        Text("No tags available")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tagViewModel.tags) { tag in
                                    TagChip(
                                        tag: tag,
                                        isSelected: selectedTags.contains(tag),
                                        onTap: {
                                            if selectedTags.contains(tag) {
                                                selectedTags.remove(tag)
                                            } else {
                                                selectedTags.insert(tag)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Section("Receipt") {
                    if let receiptImage = receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                        
                        Button("Remove Photo") {
                            self.receiptImage = nil
                        }
                        .foregroundColor(.red)
                    } else {
                        Button {
                            showingImagePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Add Receipt Photo")
                            }
                        }
                    }
                }
                
                Section("Recurring") {
                    Toggle("Make this recurring", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Repeat", selection: $recurringPattern) {
                            ForEach(RecurringPattern.allCases, id: \.self) { pattern in
                                Text(pattern.displayName).tag(pattern)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $receiptImage)
            }
            .onAppear {
                if selectedAccount == nil {
                    selectedAccount = accountViewModel.accounts.first
                }
            }
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
                if selectedCategory == nil {
                    selectedCategory = categoryViewModel.getCategories(for: selectedType).first
                }
            }
            .onChange(of: selectedType) { _, newType in
                selectedCategory = categoryViewModel.getCategories(for: newType).first
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
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        let transaction = TransactionEntity(context: transactionViewModel.viewContext)
        transaction.id = UUID()
        transaction.amount = amountValue
        transaction.type = selectedType.rawValue
        transaction.category = category
        transaction.account = selectedAccount
        transaction.date = date
        transaction.note = note.isEmpty ? nil : note
        transaction.isRecurring = isRecurring
        transaction.recurringPattern = isRecurring ? recurringPattern.rawValue : nil
        
        // Add tags
        for tag in selectedTags {
            transaction.mutableSetValue(forKey: "tags").add(tag)
        }
        
        // Add receipt image
        if let receiptImage = receiptImage {
            transaction.receiptImageData = receiptImage.jpegData(compressionQuality: 0.8)
        }
        
        transactionViewModel.persistenceController.save()
        transactionViewModel.fetchTransactions()
        
        // Update account balance
        if let account = selectedAccount {
            accountViewModel.updateBalance(for: account)
        }
        
        dismiss()
    }
}

struct CategoryPickerRow: View {
    let category: CategoryEntity
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.fromHex(category.colorHex ?? "#000000").opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: category.icon ?? "questionmark.circle")
                    .foregroundColor(Color.fromHex(category.colorHex ?? "#000000"))
                    .font(.caption)
            }
            
            Text(category.name ?? "Unknown")
                .font(.headline)
        }
    }
}

struct CategoryButton: View {
    let category: CategoryEntity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.fromHex(category.colorHex ?? "#000000").opacity(isSelected ? 0.3 : 0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon ?? "questionmark.circle")
                        .foregroundColor(Color.fromHex(category.colorHex ?? "#000000"))
                        .font(.title3)
                }
                
                Text(category.name ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
    }
}

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: TransactionEntity
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    @State private var amount: String
    @State private var selectedType: TransactionType
    @State private var selectedCategory: CategoryEntity?
    @State private var date: Date
    @State private var note: String
    
    init(transaction: TransactionEntity, transactionViewModel: TransactionViewModel, categoryViewModel: CategoryViewModel) {
        self.transaction = transaction
        self.transactionViewModel = transactionViewModel
        self.categoryViewModel = categoryViewModel
        
        _amount = State(initialValue: String(transaction.amount))
        _selectedType = State(initialValue: transaction.transactionType ?? .expense)
        _selectedCategory = State(initialValue: transaction.category)
        _date = State(initialValue: transaction.date ?? Date())
        _note = State(initialValue: transaction.note ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                }
                
                Section("Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    if let selectedCategory = selectedCategory {
                        CategoryPickerRow(category: selectedCategory)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categoryViewModel.getCategories(for: selectedType)) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Section("Date & Time") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Note") {
                    TextField("Optional note", text: $note)
                }
            }
            .navigationTitle("Edit Transaction")
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
            .onChange(of: selectedType) { _, newType in
                if selectedCategory?.transactionType != newType.rawValue {
                    selectedCategory = categoryViewModel.getCategories(for: newType).first
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
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        transactionViewModel.updateTransaction(
            transaction,
            amount: amountValue,
            type: selectedType,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note
        )
        
        dismiss()
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(
            transactionViewModel: TransactionViewModel(),
            categoryViewModel: CategoryViewModel()
        )
    }
}

