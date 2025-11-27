//
//  AccountsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct AccountsView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var accountViewModel: AccountViewModel
    @State private var showingAddAccount = false
    
    init() {
        let transactionVM = TransactionViewModel()
        _transactionViewModel = StateObject(wrappedValue: transactionVM)
        _accountViewModel = StateObject(wrappedValue: AccountViewModel(transactionViewModel: transactionVM))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Total Balance
                VStack(spacing: 8) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(CurrencyFormatter.format(accountViewModel.getTotalBalance(), currencyCode: currencyCode))
                        .font(.system(size: 36, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                
                // Accounts List
                List {
                    ForEach(accountViewModel.accounts) { account in
                        AccountRowView(
                            account: account,
                            accountViewModel: accountViewModel
                        )
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            accountViewModel.deleteAccount(accountViewModel.accounts[index])
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddAccount = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView(accountViewModel: accountViewModel)
            }
        }
    }
    
}

struct AccountRowView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let account: AccountEntity
    @ObservedObject var accountViewModel: AccountViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.fromHex(account.colorHex ?? "#000000").opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: account.icon ?? "creditcard.fill")
                    .foregroundColor(Color.fromHex(account.colorHex ?? "#000000"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name ?? "Unknown")
                    .font(.headline)
                
                Text("\(account.transactions?.count ?? 0) transactions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(CurrencyFormatter.format(account.balance, currencyCode: currencyCode))
                    .font(.headline)
                    .foregroundColor(account.balance >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var accountViewModel: AccountViewModel
    
    @State private var name: String = ""
    @State private var balance: String = "0"
    @State private var selectedIcon: String = "creditcard.fill"
    @State private var selectedColor: Color = .blue
    
    let icons = [
        "creditcard.fill", "banknote.fill", "wallet.pass.fill", "building.columns.fill",
        "dollarsign.circle.fill", "bitcoinsign.circle.fill", "giftcard.fill"
    ]
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue,
        .indigo, .purple, .pink, .brown, .gray
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account Name") {
                    TextField("Account name", text: $name)
                }
                
                Section("Initial Balance") {
                    TextField("0.00", text: $balance)
                        .keyboardType(.decimalPad)
                }
                
                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                                        .padding()
                                        .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveAccount() {
        guard let balanceValue = Double(balance) else { return }
        
        accountViewModel.addAccount(
            name: name,
            balance: balanceValue,
            icon: selectedIcon,
            color: selectedColor
        )
        
        dismiss()
    }
}

#Preview {
    AccountsView()
}

