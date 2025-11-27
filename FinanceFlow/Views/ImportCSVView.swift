//
//  ImportCSVView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportCSVView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transactionViewModel: TransactionViewModel
    @StateObject private var categoryViewModel = CategoryViewModel()
    @State private var importedTransactions: [CSVTransaction] = []
    @State private var showingFilePicker = false
    @State private var importStatus: String = ""
    
    init(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if importedTransactions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("Import Transactions from CSV")
                            .font(.headline)
                        
                        Text("Select a CSV file to import transactions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showingFilePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text("Select CSV File")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        Section {
                            Text("Found \(importedTransactions.count) transactions")
                                .font(.headline)
                        }
                        
                        Section("Preview") {
                            ForEach(Array(importedTransactions.prefix(5))) { transaction in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                    Text("\(transaction.type == .income ? "+" : "-")$\(String(format: "%.2f", transaction.amount))")
                                        .font(.headline)
                                    Text(transaction.category ?? "Unknown")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if importedTransactions.count > 5 {
                                Text("... and \(importedTransactions.count - 5) more")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section {
                            Button {
                                importTransactions()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Import All Transactions")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                importedTransactions = []
                                importStatus = ""
                            } label: {
                                Text("Clear")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    if !importStatus.isEmpty {
                        Text(importStatus)
                            .foregroundColor(importStatus.contains("Success") ? .green : .red)
                            .padding()
                    }
                }
            }
            .navigationTitle("Import CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .text],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        parseCSV(from: url)
                    }
                case .failure(let error):
                    importStatus = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func parseCSV(from url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            guard lines.count > 1 else {
                importStatus = "CSV file is empty"
                return
            }
            
            var transactions: [CSVTransaction] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for (index, line) in lines.enumerated() {
                if index == 0 { continue } // Skip header
                
                let components = line.components(separatedBy: ",")
                guard components.count >= 4 else { continue }
                
                let dateString = components[0].trimmingCharacters(in: .whitespaces)
                let typeString = components[1].trimmingCharacters(in: .whitespaces)
                let category = components[2].trimmingCharacters(in: .whitespaces)
                let amountString = components[3].trimmingCharacters(in: .whitespaces)
                let note = components.count > 4 ? components[4].trimmingCharacters(in: .whitespaces) : nil
                
                guard let date = dateFormatter.date(from: dateString),
                      let amount = Double(amountString),
                      let type = TransactionType(rawValue: typeString.lowercased()) else {
                    continue
                }
                
                transactions.append(CSVTransaction(
                    date: date,
                    type: type,
                    category: category,
                    amount: amount,
                    note: note
                ))
            }
            
            importedTransactions = transactions
            importStatus = "Successfully parsed \(transactions.count) transactions"
        } catch {
            importStatus = "Error reading file: \(error.localizedDescription)"
        }
    }
    
    private func importTransactions() {
        var imported = 0
        var errors = 0
        
        for csvTransaction in importedTransactions {
            // Find or create category
            let category = categoryViewModel.categories.first { $0.name?.lowercased() == csvTransaction.category.lowercased() }
                ?? categoryViewModel.getCategories(for: csvTransaction.type).first
            
            guard let category = category else {
                errors += 1
                continue
            }
            
            transactionViewModel.addTransaction(
                amount: csvTransaction.amount,
                type: csvTransaction.type,
                category: category,
                date: csvTransaction.date,
                note: csvTransaction.note
            )
            imported += 1
        }
        
        importStatus = "Imported \(imported) transactions. \(errors > 0 ? "\(errors) errors." : "")"
        importedTransactions = []
    }
}

struct CSVTransaction: Identifiable {
    let id = UUID()
    let date: Date
    let type: TransactionType
    let category: String
    let amount: Double
    let note: String?
}

#Preview {
    ImportCSVView(transactionViewModel: TransactionViewModel())
}

