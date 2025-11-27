//
//  TemplatesView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct TemplatesView: View {
    @StateObject private var templateViewModel = TemplateViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var transactionViewModel = TransactionViewModel()
    @State private var showingAddTemplate = false
    
    var body: some View {
        NavigationStack {
            List {
                if templateViewModel.templates.isEmpty {
                    EmptyTemplatesView()
                } else {
                    ForEach(templateViewModel.templates) { template in
                        TemplateRowView(
                            template: template,
                            templateViewModel: templateViewModel,
                            transactionViewModel: transactionViewModel
                        )
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            templateViewModel.deleteTemplate(templateViewModel.templates[index])
                        }
                    }
                }
            }
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTemplate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddTemplateView(
                    templateViewModel: templateViewModel,
                    categoryViewModel: categoryViewModel
                )
            }
        }
    }
}

struct TemplateRowView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let template: TransactionTemplateEntity
    @ObservedObject var templateViewModel: TemplateViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name ?? "Unknown")
                    .font(.headline)
                
                if let category = template.category {
                    HStack {
                        Image(systemName: category.icon ?? "questionmark.circle")
                            .foregroundColor(Color.fromHex(category.colorHex ?? "#000000"))
                        Text(category.name ?? "Unknown")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(template.amount))
                    .font(.headline)
                    .foregroundColor(TransactionType(rawValue: template.type ?? "expense")?.color ?? .primary)
                
                Button {
                    useTemplate()
                } label: {
                    Text("Use")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func useTemplate() {
        let transaction = templateViewModel.createTransaction(from: template)
        transactionViewModel.persistenceController.save()
        transactionViewModel.fetchTransactions()
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyFormatter.format(amount, currencyCode: currencyCode)
    }
}

struct EmptyTemplatesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No templates")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Create templates for frequent transactions")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AddTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var templateViewModel: TemplateViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: CategoryEntity?
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Template Name") {
                    TextField("Template name", text: $name)
                }
                
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
                
                Section("Note") {
                    TextField("Optional note", text: $note)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTemplate()
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
        guard !name.isEmpty,
              let amountValue = Double(amount),
              amountValue > 0,
              selectedCategory != nil else {
            return false
        }
        return true
    }
    
    private func saveTemplate() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        templateViewModel.addTemplate(
            name: name,
            amount: amountValue,
            type: selectedType,
            category: category,
            note: note.isEmpty ? nil : note
        )
        
        dismiss()
    }
}

#Preview {
    TemplatesView()
}

