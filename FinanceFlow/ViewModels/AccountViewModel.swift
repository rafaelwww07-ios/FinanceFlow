//
//  AccountViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class AccountViewModel: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var accounts: [AccountEntity] = []
    @Published var isLoading = false
    @Published var selectedAccount: AccountEntity?
    
    private let transactionViewModel: TransactionViewModel
    
    init(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
        fetchAccounts()
        if accounts.isEmpty {
            createDefaultAccount()
        }
        if selectedAccount == nil {
            selectedAccount = accounts.first
        }
    }
    
    func fetchAccounts() {
        isLoading = true
        let request: NSFetchRequest<AccountEntity> = AccountEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.name, ascending: true)]
        
        do {
            accounts = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch accounts: \(error)")
        }
        isLoading = false
    }
    
    private func createDefaultAccount() {
        let account = AccountEntity(context: viewContext)
        account.id = UUID()
        account.name = "Main Account"
        account.balance = 0
        account.icon = "creditcard.fill"
        account.colorHex = Color.blue.toHex()
        
        persistenceController.save()
        fetchAccounts()
    }
    
    func addAccount(
        name: String,
        balance: Double,
        icon: String,
        color: Color
    ) {
        let account = AccountEntity(context: viewContext)
        account.id = UUID()
        account.name = name
        account.balance = balance
        account.icon = icon
        account.colorHex = color.toHex()
        
        persistenceController.save()
        fetchAccounts()
    }
    
    func updateAccount(
        _ account: AccountEntity,
        name: String,
        icon: String,
        color: Color
    ) {
        account.name = name
        account.icon = icon
        account.colorHex = color.toHex()
        
        persistenceController.save()
        fetchAccounts()
    }
    
    func deleteAccount(_ account: AccountEntity) {
        viewContext.delete(account)
        persistenceController.save()
        fetchAccounts()
    }
    
    func updateBalance(for account: AccountEntity) {
        let transactions = transactionViewModel.transactions.filter { $0.account?.id == account.id }
        let balance = transactions.reduce(0) { total, transaction in
            if transaction.transactionType == .income {
                return total + transaction.amount
            } else {
                return total - transaction.amount
            }
        }
        account.balance = balance
        persistenceController.save()
    }
    
    func getTotalBalance() -> Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
}



