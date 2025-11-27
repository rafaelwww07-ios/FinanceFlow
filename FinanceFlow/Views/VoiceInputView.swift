//
//  VoiceInputView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import Speech

struct VoiceInputView: View {
    @StateObject private var voiceService = VoiceInputService.shared
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var parsedTransaction: ParsedTransaction?
    @State private var showingConfirmView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Recording Indicator
                if voiceService.isRecording {
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.3), lineWidth: 4)
                                    .scaleEffect(voiceService.isRecording ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: voiceService.isRecording)
                            )
                        
                        Text("Listening...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
                
                // Recognized Text
                if !voiceService.recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recognized:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(voiceService.recognizedText)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Parsed Transaction Preview
                if let parsed = parsedTransaction {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Parsed Transaction:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(CurrencyFormatter.format(parsed.amount, currencyCode: "USD"))
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(parsed.type.displayName)
                                .font(.subheadline)
                                .foregroundColor(parsed.type.color)
                        }
                        
                        if let category = parsed.category {
                            Text("Category: \(category)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Control Buttons
                HStack(spacing: 20) {
                    if voiceService.isRecording {
                        Button {
                            voiceService.stopRecording()
                            if let parsed = voiceService.parseTransaction(from: voiceService.recognizedText) {
                                parsedTransaction = parsed
                            }
                        } label: {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    } else {
                        Button {
                            voiceService.startRecording()
                        } label: {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("Start Recording")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(voiceService.isAuthorized ? Color.blue : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!voiceService.isAuthorized)
                    }
                }
                .padding(.horizontal)
                
                if let parsed = parsedTransaction {
                    Button {
                        showingConfirmView = true
                    } label: {
                        Text("Confirm Transaction")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Voice Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingConfirmView) {
                if let parsed = parsedTransaction {
                    ConfirmVoiceTransactionView(
                        parsedTransaction: parsed,
                        transactionViewModel: transactionViewModel,
                        categoryViewModel: categoryViewModel,
                        onConfirm: {
                            dismiss()
                        }
                    )
                }
            }
        }
    }
}

struct ConfirmVoiceTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    let parsedTransaction: ParsedTransaction
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    @State private var selectedCategory: CategoryEntity?
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    let onConfirm: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    Text(CurrencyFormatter.format(parsedTransaction.amount, currencyCode: "USD"))
                        .font(.headline)
                }
                
                Section("Type") {
                    Text(parsedTransaction.type.displayName)
                        .foregroundColor(parsedTransaction.type.color)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        if let suggestedCategory = parsedTransaction.category,
                           let category = categoryViewModel.categories.first(where: { $0.name == suggestedCategory }) {
                            Text(category.name ?? "Unknown").tag(category as CategoryEntity?)
                        }
                        
                        ForEach(categoryViewModel.getCategories(for: parsedTransaction.type)) { category in
                            Text(category.name ?? "Unknown").tag(category as CategoryEntity?)
                        }
                    }
                }
                
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Note") {
                    TextField("Note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Confirm Transaction")
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
                    .disabled(selectedCategory == nil)
                }
            }
            .onAppear {
                if let suggestedCategory = parsedTransaction.category {
                    selectedCategory = categoryViewModel.categories.first(where: { $0.name == suggestedCategory })
                } else {
                    selectedCategory = categoryViewModel.getCategories(for: parsedTransaction.type).first
                }
                note = parsedTransaction.note
            }
        }
    }
    
    private func saveTransaction() {
        guard let category = selectedCategory else { return }
        
        transactionViewModel.addTransaction(
            amount: parsedTransaction.amount,
            type: parsedTransaction.type,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note
        )
        
        onConfirm()
        dismiss()
    }
}



