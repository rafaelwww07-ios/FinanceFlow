//
//  SettingsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD" {
        didSet {
            AppGroupManager.shared.setCurrencyCode(currencyCode)
        }
    }
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("budgetAlertsEnabled") private var budgetAlertsEnabled: Bool = true
    @StateObject private var transactionViewModel = TransactionViewModel()
    @State private var showingExportPDF = false
    @State private var showingImportCSV = false
    
    let currencies = ["USD", "EUR", "GBP", "RUB", "JPY", "CNY"]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Currency") {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Budget Alerts", isOn: $budgetAlertsEnabled)
                        .disabled(!notificationsEnabled)
                }
                
                Section("iCloud Sync") {
                    Toggle("Enable iCloud Sync", isOn: Binding(
                        get: { CloudKitService.shared.isSyncEnabled() },
                        set: { enabled in
                            if enabled {
                                CloudKitService.shared.enableSync()
                            } else {
                                CloudKitService.shared.disableSync()
                            }
                        }
                    ))
                    
                    Text("Sync your data across all your devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Quick Actions") {
                    NavigationLink {
                        TemplatesView()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Transaction Templates")
                        }
                    }
                    
                    NavigationLink {
                        TagsManagementView()
                    } label: {
                        HStack {
                            Image(systemName: "tag.fill")
                            Text("Manage Tags")
                        }
                    }
                    
                    NavigationLink {
                        CurrencyConverterView()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right.circle.fill")
                            Text("Currency Converter")
                        }
                    }
                    
                    NavigationLink {
                        SecurityView()
                    } label: {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                            Text("Security")
                        }
                    }
                    
                    NavigationLink {
                        ThemeSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                            Text("Appearance")
                        }
                    }
                }
                
                Section("Advanced Features") {
                    NavigationLink {
                        AdvancedAnalyticsView(transactionViewModel: transactionViewModel)
                    } label: {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Advanced Analytics")
                        }
                    }
                    
                    NavigationLink {
                        VoiceInputView(
                            transactionViewModel: transactionViewModel,
                            categoryViewModel: CategoryViewModel()
                        )
                    } label: {
                        HStack {
                            Image(systemName: "mic.fill")
                            Text("Voice Input")
                        }
                    }
                    
                    NavigationLink {
                        BankImportView(
                            transactionViewModel: transactionViewModel,
                            categoryViewModel: CategoryViewModel()
                        )
                    } label: {
                        HStack {
                            Image(systemName: "building.columns.fill")
                            Text("Import from Bank")
                        }
                    }
                }
                
                Section("Data Management") {
                    NavigationLink {
                        ExportOptionsView(transactionViewModel: transactionViewModel)
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Export Data")
                        }
                    }
                    
                    Button {
                        showingImportCSV = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Import from CSV")
                        }
                    }
                    
                    Button(role: .destructive) {
                        // Clear all data
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear All Data")
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportPDF) {
                ExportPDFView(transactionViewModel: transactionViewModel)
            }
            .sheet(isPresented: $showingImportCSV) {
                ImportCSVView(transactionViewModel: transactionViewModel)
            }
        }
    }
}

#Preview {
    SettingsView()
}

