//
//  FinanceFlowApp.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import CoreData

@main
struct FinanceFlowApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Request notification permissions on app launch
        NotificationService.shared.requestAuthorization()
        
        // Синхронизация валюты с App Group для виджетов
        if let currencyCode = AppGroupManager.shared.getCurrencyCode() {
            UserDefaults.standard.set(currencyCode, forKey: "currencyCode")
        } else {
            AppGroupManager.shared.setCurrencyCode("USD")
        }
        
        // Обработка транзакций из Siri Shortcuts
        processPendingTransactions()
    }
    
    private func processPendingTransactions() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.financeflow.app"),
              let pendingTransactions = userDefaults.array(forKey: "pendingTransactions") as? [[String: Any]],
              !pendingTransactions.isEmpty else {
            return
        }
        
        // Обрабатываем транзакции при следующем запуске приложения
        // Это будет обработано в TransactionViewModel
        userDefaults.removeObject(forKey: "pendingTransactions")
        userDefaults.synchronize()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
