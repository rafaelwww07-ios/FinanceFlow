//
//  CurrencyConverterView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct CurrencyConverterView: View {
    @StateObject private var exchangeService = CurrencyExchangeService.shared
    @AppStorage("currencyCode") private var baseCurrency: String = "USD"
    
    @State private var amount: String = "100"
    @State private var fromCurrency: String = "USD"
    @State private var toCurrency: String = "EUR"
    
    let currencies = ["USD", "EUR", "GBP", "RUB", "JPY", "CNY", "CHF", "AUD", "CAD"]
    
    var convertedAmount: Double {
        guard let amountValue = Double(amount) else { return 0 }
        return exchangeService.convert(amount: amountValue, from: fromCurrency, to: toCurrency)
    }
    
    var exchangeRate: Double {
        exchangeService.getRate(from: fromCurrency, to: toCurrency)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section("From Currency") {
                    Picker("From", selection: $fromCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                Section("To Currency") {
                    Picker("To", selection: $toCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                Section("Result") {
                    HStack {
                        Text("Converted Amount:")
                        Spacer()
                        Text(CurrencyFormatter.format(convertedAmount, currencyCode: toCurrency))
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("Exchange Rate:")
                        Spacer()
                        Text("1 \(fromCurrency) = \(String(format: "%.4f", exchangeRate)) \(toCurrency)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await exchangeService.fetchExchangeRates()
                        }
                    } label: {
                        HStack {
                            if exchangeService.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Update Exchange Rates")
                        }
                    }
                    .disabled(exchangeService.isLoading)
                    
                    if let lastUpdate = exchangeService.lastUpdate {
                        HStack {
                            Text("Last Updated:")
                            Spacer()
                            Text(lastUpdate.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Currency Converter")
            .onAppear {
                if exchangeService.exchangeRates.isEmpty {
                    Task {
                        await exchangeService.fetchExchangeRates()
                    }
                }
            }
        }
    }
}



