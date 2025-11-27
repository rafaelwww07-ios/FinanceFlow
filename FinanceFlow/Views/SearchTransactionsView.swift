//
//  SearchTransactionsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct SearchTransactionsView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedCategory: CategoryEntity?
    @State private var selectedType: TransactionType?
    @State private var dateRange: ClosedRange<Date>?
    @State private var minAmount: String = ""
    @State private var maxAmount: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search transactions...", text: $searchText)
                        .onChange(of: searchText) { _, newValue in
                            transactionViewModel.searchText = newValue
                            transactionViewModel.applyFilters()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            transactionViewModel.searchText = ""
                            transactionViewModel.applyFilters()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Category filter
                        Menu {
                            Button("All Categories") {
                                selectedCategory = nil
                                transactionViewModel.selectedCategoryFilter = nil
                                transactionViewModel.applyFilters()
                            }
                            
                            ForEach(categoryViewModel.categories) { category in
                                Button(category.name ?? "Unknown") {
                                    selectedCategory = category
                                    transactionViewModel.selectedCategoryFilter = category
                                    transactionViewModel.applyFilters()
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text(selectedCategory?.name ?? "All Categories")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory != nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Type filter
                        Menu {
                            Button("All Types") {
                                selectedType = nil
                                transactionViewModel.selectedTypeFilter = nil
                                transactionViewModel.applyFilters()
                            }
                            
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Button(type.displayName) {
                                    selectedType = type
                                    transactionViewModel.selectedTypeFilter = type
                                    transactionViewModel.applyFilters()
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: selectedType?.icon ?? "arrow.up.arrow.down")
                                Text(selectedType?.displayName ?? "All Types")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedType != nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Date range filter
                        Button {
                            // Show date picker
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Date Range")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Clear filters
                        if selectedCategory != nil || selectedType != nil || dateRange != nil {
                            Button {
                                selectedCategory = nil
                                selectedType = nil
                                dateRange = nil
                                transactionViewModel.clearFilters()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Clear")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Results
                List {
                    ForEach(transactionViewModel.filteredTransactions) { transaction in
                        SearchTransactionRowView(transaction: transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    transactionViewModel.deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

