//
//  CurrencyExchangeService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import Combine

class CurrencyExchangeService: ObservableObject {
    static let shared = CurrencyExchangeService()
    
    @Published var exchangeRates: [String: Double] = [:]
    @Published var lastUpdate: Date?
    @Published var isLoading = false
    
    private let baseCurrency = "USD"
    private let cacheKey = "exchangeRates"
    private let cacheDateKey = "exchangeRatesDate"
    
    private init() {
        loadCachedRates()
    }
    
    func fetchExchangeRates() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Используем бесплатный API exchangerate-api.com
        // В реальном приложении можно использовать другие API (Fixer.io, CurrencyLayer и т.д.)
        let urlString = "https://api.exchangerate-api.com/v4/latest/\(baseCurrency)"
        
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            await MainActor.run {
                exchangeRates = response.rates
                lastUpdate = Date()
                saveCachedRates()
                isLoading = false
            }
        } catch {
            print("Error fetching exchange rates: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func convert(amount: Double, from: String, to: String) -> Double {
        guard from != to else { return amount }
        
        // Если базовая валюта USD
        if from == baseCurrency {
            return amount * (exchangeRates[to] ?? 1.0)
        } else if to == baseCurrency {
            return amount / (exchangeRates[from] ?? 1.0)
        } else {
            // Конвертация через базовую валюту
            let baseAmount = amount / (exchangeRates[from] ?? 1.0)
            return baseAmount * (exchangeRates[to] ?? 1.0)
        }
    }
    
    func getRate(from: String, to: String) -> Double {
        guard from != to else { return 1.0 }
        
        if from == baseCurrency {
            return exchangeRates[to] ?? 1.0
        } else if to == baseCurrency {
            return 1.0 / (exchangeRates[from] ?? 1.0)
        } else {
            let fromRate = exchangeRates[from] ?? 1.0
            let toRate = exchangeRates[to] ?? 1.0
            return toRate / fromRate
        }
    }
    
    private func saveCachedRates() {
        UserDefaults.standard.set(exchangeRates, forKey: cacheKey)
        UserDefaults.standard.set(lastUpdate, forKey: cacheDateKey)
    }
    
    private func loadCachedRates() {
        if let rates = UserDefaults.standard.dictionary(forKey: cacheKey) as? [String: Double] {
            exchangeRates = rates
        }
        if let date = UserDefaults.standard.object(forKey: cacheDateKey) as? Date {
            lastUpdate = date
            // Обновляем курсы если прошло больше 24 часов
            if Date().timeIntervalSince(date) > 86400 {
                Task {
                    await fetchExchangeRates()
                }
            }
        } else {
            // Загружаем курсы при первом запуске
            Task {
                await fetchExchangeRates()
            }
        }
    }
}

struct ExchangeRateResponse: Codable {
    let base: String
    let date: String
    let rates: [String: Double]
}



