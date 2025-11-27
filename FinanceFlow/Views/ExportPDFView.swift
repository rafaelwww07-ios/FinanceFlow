//
//  ExportPDFView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import PDFKit

struct ExportPDFView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var selectedPeriod: StatisticsPeriod = .month
    @State private var pdfData: Data?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                Button {
                    generatePDF()
                } label: {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text("Generate PDF Report")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                if pdfData != nil {
                    PDFKitView(data: pdfData!)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button {
                        showingShareSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share PDF")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Export PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = pdfData {
                    ShareSheet(activityItems: [pdfData])
                }
            }
        }
    }
    
    private func generatePDF() {
        let transactions = transactionViewModel.getTransactions(for: selectedPeriod)
        
        let pdfMetaData = [
            kCGPDFContextCreator: "FinanceFlow",
            kCGPDFContextAuthor: "FinanceFlow App",
            kCGPDFContextTitle: "Financial Report - \(selectedPeriod.rawValue)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 72
            
            // Title
            let title = "Financial Report - \(selectedPeriod.rawValue)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = "Generated: \(dateFormatter.string(from: Date()))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
            dateString.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // Summary
            let totalIncome = transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
            let totalExpense = transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
            let balance = totalIncome - totalExpense
            
            let summary = """
            Summary:
            Total Income: $\(String(format: "%.2f", totalIncome))
            Total Expense: $\(String(format: "%.2f", totalExpense))
            Balance: $\(String(format: "%.2f", balance))
            """
            
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]
            let summarySize = summary.size(withAttributes: summaryAttributes)
            summary.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: summaryAttributes)
            yPosition += summarySize.height + 30
            
            // Transactions
            let transactionsTitle = "Transactions:"
            transactionsTitle.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: titleAttributes)
            yPosition += 30
            
            for transaction in transactions {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 72
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                let transactionText = """
                \(dateFormatter.string(from: transaction.date ?? Date())) - \(transaction.category?.name ?? "Unknown")
                \(transaction.transactionType == .income ? "+" : "-")$\(String(format: "%.2f", transaction.amount))
                \(transaction.note ?? "")
                """
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: transaction.transactionType == .income ? UIColor.systemGreen : UIColor.systemRed
                ]
                
                let textSize = transactionText.size(withAttributes: textAttributes)
                transactionText.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: textAttributes)
                yPosition += textSize.height + 15
            }
        }
        
        pdfData = data
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

#Preview {
    ExportPDFView(transactionViewModel: TransactionViewModel())
}



