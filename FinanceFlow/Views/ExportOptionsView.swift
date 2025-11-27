//
//  ExportOptionsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct ExportOptionsView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationStack {
            List {
                Section("Export Formats") {
                    Button {
                        exportToCSV()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Export to CSV")
                        }
                    }
                    
                    Button {
                        exportToExcel()
                    } label: {
                        HStack {
                            Image(systemName: "tablecells.fill")
                            Text("Export to Excel")
                        }
                    }
                    
                    Button {
                        exportToPDF()
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("Export to PDF")
                        }
                    }
                }
                
                Section("Reports") {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(2020...2030, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    
                    Button {
                        exportYearlyReport()
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Yearly Report")
                        }
                    }
                    
                    Button {
                        exportTaxReport()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("Tax Report")
                        }
                    }
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: shareItems)
            }
        }
    }
    
    private func exportToCSV() {
        let csv = ExportService.shared.exportToCSV(
            transactions: transactionViewModel.transactions,
            currencyCode: currencyCode
        )
        shareItems = [csv]
        showingShareSheet = true
    }
    
    private func exportToExcel() {
        if let excelData = ExcelExportService.shared.exportToXLSX(
            transactions: transactionViewModel.transactions,
            currencyCode: currencyCode
        ) {
            shareItems = [excelData]
            showingShareSheet = true
        }
    }
    
    private func exportToPDF() {
        if let pdfData = ExportService.shared.generatePDF(
            transactions: transactionViewModel.transactions,
            currencyCode: currencyCode
        ) {
            shareItems = [pdfData]
            showingShareSheet = true
        }
    }
    
    private func exportYearlyReport() {
        let report = ExportService.shared.generateYearlyReport(
            transactions: transactionViewModel.transactions,
            year: selectedYear,
            currencyCode: currencyCode
        )
        shareItems = [report]
        showingShareSheet = true
    }
    
    private func exportTaxReport() {
        let report = ExportService.shared.generateTaxReport(
            transactions: transactionViewModel.transactions,
            year: selectedYear,
            currencyCode: currencyCode
        )
        shareItems = [report]
        showingShareSheet = true
    }
}

