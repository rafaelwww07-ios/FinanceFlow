//
//  StatisticsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var statisticsViewModel: StatisticsViewModel
    
    @State private var showingExportSheet = false
    @State private var exportData: String = ""
    @State private var showingComparison = false
    @State private var comparisonPeriod: StatisticsPeriod = .month
    
    init() {
        let transactionVM = TransactionViewModel()
        let categoryVM = CategoryViewModel()
        _transactionViewModel = StateObject(wrappedValue: transactionVM)
        _categoryViewModel = StateObject(wrappedValue: categoryVM)
        _statisticsViewModel = StateObject(wrappedValue: StatisticsViewModel(transactionViewModel: transactionVM, categoryViewModel: categoryVM))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Picker
                    PeriodPickerView(selectedPeriod: $statisticsViewModel.selectedPeriod)
                        .onChange(of: statisticsViewModel.selectedPeriod) { _, _ in
                            statisticsViewModel.updateStatistics()
                        }
                    
                    // Chart
                    ChartView(data: statisticsViewModel.chartData)
                        .frame(height: 300)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Category Statistics
                    CategoryStatisticsView(stats: statisticsViewModel.categoryStats)
                    
                    // Comparison Section
                    ComparisonSectionView(
                        transactionViewModel: transactionViewModel,
                        currentPeriod: statisticsViewModel.selectedPeriod,
                        comparisonPeriod: $comparisonPeriod
                    )
                    
                    // Export Button
                    ExportButton {
                        exportData = statisticsViewModel.exportToCSV()
                        showingExportSheet = true
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(activityItems: [exportData])
            }
            .onAppear {
                statisticsViewModel.updateStatistics()
            }
        }
    }
}

struct PeriodPickerView: View {
    @Binding var selectedPeriod: StatisticsPeriod
    
    var body: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct ChartView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let data: [ChartDataPoint]
    
    var body: some View {
        if data.isEmpty {
            VStack {
                Image(systemName: "chart.bar")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text("No data available")
                    .foregroundColor(.secondary)
            }
        } else {
            Chart(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Income", point.income)
                )
                .foregroundStyle(Color.green)
                .cornerRadius(4)
                
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Expense", -point.expense)
                )
                .foregroundStyle(Color.red)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(formatCurrency(abs(doubleValue)))
                        }
                    }
                }
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct CategoryStatisticsView: View {
    let stats: [CategoryStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Category")
                .font(.headline)
                .padding(.horizontal)
            
            if stats.isEmpty {
                VStack {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No category data")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Pie Chart
                PieChartView(stats: stats)
                    .frame(height: 250)
                    .padding()
                
                // Category List
                VStack(spacing: 12) {
                    ForEach(stats) { stat in
                        CategoryStatRow(stat: stat)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PieChartView: View {
    let stats: [CategoryStat]
    
    var body: some View {
        Chart(stats) { stat in
            SectorMark(
                angle: .value("Amount", stat.amount),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(stat.category.color)
            .annotation(position: .overlay) {
                if stat.percentage > 5 {
                    Text("\(Int(stat.percentage))%")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct CategoryStatRow: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let stat: CategoryStat
    
    var body: some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(stat.category.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: stat.category.icon)
                    .foregroundColor(stat.category.color)
                    .font(.caption)
            }
            
            // Category Name
            Text(stat.category.name)
                .font(.headline)
            
            Spacer()
            
            // Percentage Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(stat.category.color)
                        .frame(width: geometry.size.width * CGFloat(stat.percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(width: 100, height: 8)
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(stat.amount, currencyCode: currencyCode, maximumFractionDigits: 0))
                    .font(.headline)
                Text("\(String(format: "%.1f", stat.percentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ExportButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export to CSV")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    StatisticsView()
}

