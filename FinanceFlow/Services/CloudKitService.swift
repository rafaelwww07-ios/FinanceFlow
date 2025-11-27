//
//  CloudKitService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CloudKit
import CoreData

class CloudKitService {
    static let shared = CloudKitService()
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let publicDatabase: CKDatabase
    
    private init() {
        container = CKContainer(identifier: CloudKitConfig.containerIdentifier)
        privateDatabase = container.privateCloudDatabase
        publicDatabase = container.publicCloudDatabase
    }
    
    func checkAccountStatus() async -> Bool {
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            print("Error checking CloudKit account status: \(error)")
            return false
        }
    }
    
    func syncTransactions(_ transactions: [TransactionEntity]) async throws {
        // В реальном приложении здесь будет синхронизация с CloudKit
        // Это базовая структура для будущей реализации
        print("Syncing \(transactions.count) transactions to iCloud...")
    }
    
    func fetchFromCloud() async throws -> [TransactionEntity] {
        // Загрузка транзакций из CloudKit
        print("Fetching transactions from iCloud...")
        return []
    }
    
    func enableSync() {
        UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")
    }
    
    func disableSync() {
        UserDefaults.standard.set(false, forKey: "iCloudSyncEnabled")
    }
    
    func isSyncEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }
}


