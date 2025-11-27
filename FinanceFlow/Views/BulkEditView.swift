//
//  BulkEditView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct BulkEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    let selectedTransactions: [TransactionEntity]
    
    @State private var selectedCategory: CategoryEntity?
    @State private var selectedTags: Set<TagEntity> = []
    @State private var showCategoryPicker = false
    @State private var showTagPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Selected Transactions") {
                    Text("\(selectedTransactions.count) transactions selected")
                        .foregroundColor(.secondary)
                }
                
                Section("Change Category") {
                    if let selectedCategory = selectedCategory {
                        HStack {
                            Text("New Category:")
                            Spacer()
                            Text(selectedCategory.name ?? "Unknown")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button {
                        showCategoryPicker = true
                    } label: {
                        Text("Select Category")
                    }
                }
                
                Section("Add Tags") {
                    if !selectedTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedTags), id: \.id) { tag in
                                    TagChip(
                                        tag: tag,
                                        isSelected: true,
                                        onTap: {
                                            selectedTags.remove(tag)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    Button {
                        showTagPicker = true
                    } label: {
                        Text("Select Tags")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        deleteSelected()
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Selected")
                        }
                    }
                }
            }
            .navigationTitle("Bulk Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyChanges()
                    }
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory, categoryViewModel: categoryViewModel)
            }
        }
    }
    
    private func applyChanges() {
        for transaction in selectedTransactions {
            if let category = selectedCategory {
                transaction.category = category
            }
            
            // Добавляем теги
            if !selectedTags.isEmpty {
                let currentTags = transaction.tags as? Set<TagEntity> ?? []
                let newTags = currentTags.union(selectedTags)
                transaction.tags = NSSet(set: newTags)
            }
        }
        
        transactionViewModel.saveContext()
        dismiss()
    }
    
    private func deleteSelected() {
        for transaction in selectedTransactions {
            transactionViewModel.deleteTransaction(transaction)
        }
        dismiss()
    }
}

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: CategoryEntity?
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categoryViewModel.categories) { category in
                    Button {
                        selectedCategory = category
                        dismiss()
                    } label: {
                        HStack {
                            Text(category.name ?? "Unknown")
                            Spacer()
                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


