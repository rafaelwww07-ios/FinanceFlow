//
//  BankImportView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var commaSeparatedText: UTType {
        UTType(filenameExtension: "csv") ?? .text
    }
}

struct BankImportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    @State private var selectedBank: BankImportService.SupportedBank = .manual
    @State private var showingFilePicker = false
    @State private var importedTransactions: [ImportedTransaction] = []
    @State private var showingPreview = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Bank") {
                    Picker("Bank", selection: $selectedBank) {
                        ForEach(BankImportService.SupportedBank.allCases, id: \.self) { bank in
                            HStack {
                                Image(systemName: bank.icon)
                                Text(bank.rawValue)
                            }
                            .tag(bank)
                        }
                    }
                }
                
                Section("Import File") {
                    Button {
                        showingFilePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("Select File")
                        }
                    }
                    
                    if !importedTransactions.isEmpty {
                        Text("\(importedTransactions.count) transactions found")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !importedTransactions.isEmpty {
                    Section {
                        Button {
                            showingPreview = true
                        } label: {
                            HStack {
                                Image(systemName: "eye.fill")
                                Text("Preview Transactions")
                            }
                        }
                        
                        Button {
                            importTransactions()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Import All")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Import from Bank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType.commaSeparatedText, UTType.plainText, UTType.data],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .sheet(isPresented: $showingPreview) {
                ImportPreviewView(
                    transactions: importedTransactions,
                    transactionViewModel: transactionViewModel,
                    categoryViewModel: categoryViewModel,
                    onImport: {
                        importTransactions()
                    }
                )
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                importedTransactions = BankImportService.shared.importFromCSV(data: data, bank: selectedBank)
                
                // Auto-categorize
                for (index, transaction) in importedTransactions.enumerated() {
                    if let category = BankImportService.shared.categorizeTransaction(transaction) {
                        importedTransactions[index].category = category
                    }
                }
            } catch {
                print("Error reading file: \(error)")
            }
            
        case .failure(let error):
            print("File selection error: \(error)")
        }
    }
    
    private func importTransactions() {
        for imported in importedTransactions {
            let category = categoryViewModel.categories.first { $0.name == imported.category } ??
                          categoryViewModel.getCategories(for: imported.type).first
            
            guard let category = category else { continue }
            
            transactionViewModel.addTransaction(
                amount: imported.amount,
                type: imported.type,
                category: category,
                date: imported.date,
                note: imported.description
            )
        }
        
        dismiss()
    }
}

struct ImportPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let transactions: [ImportedTransaction]
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    let onImport: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(transactions.enumerated()), id: \.offset) { index, transaction in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(CurrencyFormatter.format(transaction.amount, currencyCode: "USD"))
                                .font(.headline)
                                .foregroundColor(transaction.type.color)
                            
                            Spacer()
                            
                            Text(transaction.type.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(transaction.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let category = transaction.category {
                            Text("Category: \(category)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Preview (\(transactions.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        onImport()
                        dismiss()
                    }
                }
            }
        }
    }
}

