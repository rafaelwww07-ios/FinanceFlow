//
//  AppGroupManager.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation

class AppGroupManager {
    static let shared = AppGroupManager()
    
    private let appGroupIdentifier = "group.com.financeflow.app"
    private let userDefaults: UserDefaults?
    
    init() {
        userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // Синхронизация валюты между приложением и виджетом
    func setCurrencyCode(_ code: String) {
        userDefaults?.set(code, forKey: "currencyCode")
        userDefaults?.synchronize()
    }
    
    func getCurrencyCode() -> String? {
        return userDefaults?.string(forKey: "currencyCode")
    }
    
    // Синхронизация других настроек
    func setValue(_ value: Any?, forKey key: String) {
        userDefaults?.set(value, forKey: key)
        userDefaults?.synchronize()
    }
    
    func getValue(forKey key: String) -> Any? {
        return userDefaults?.object(forKey: key)
    }
}


