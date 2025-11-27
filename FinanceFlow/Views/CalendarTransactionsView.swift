//
//  CalendarTransactionsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct CalendarTransactionsView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var selectedDate: Date = Date()
    @State private var selectedMonth: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month selector
                HStack {
                    Button {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                // Calendar
                CalendarView(
                    selectedDate: $selectedDate,
                    month: selectedMonth,
                    transactions: transactionViewModel.transactions
                )
                
                // Transactions for selected date
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transactions for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    let dayTransactions = getTransactions(for: selectedDate)
                    
                    if dayTransactions.isEmpty {
                        VStack {
                            Text("No transactions on this day")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        List {
                            ForEach(dayTransactions) { transaction in
                                SearchTransactionRowView(transaction: transaction)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            transactionViewModel.deleteTransaction(transaction)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
        }
    }
    
    private func getTransactions(for date: Date) -> [TransactionEntity] {
        let calendar = Calendar.current
        return transactionViewModel.transactions.filter { transaction in
            guard let transactionDate = transaction.date else { return false }
            return calendar.isDate(transactionDate, inSameDayAs: date)
        }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    let month: Date
    let transactions: [TransactionEntity]
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month),
                            hasTransactions: hasTransactions(on: date),
                            onTap: {
                                selectedDate = date
                            }
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding()
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstDay = calendar.dateInterval(of: .month, for: month)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        // Fill remaining days to complete grid
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasTransactions(on date: Date) -> Bool {
        return transactions.contains { transaction in
            guard let transactionDate = transaction.date else { return false }
            return calendar.isDate(transactionDate, inSameDayAs: date)
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasTransactions: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isCurrentMonth ? (isSelected ? .white : .primary) : .secondary)
                
                if hasTransactions {
                    Circle()
                        .fill(isSelected ? Color.white : Color.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 40, height: 40)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
        }
    }
}

#Preview {
    CalendarTransactionsView(transactionViewModel: TransactionViewModel())
}

