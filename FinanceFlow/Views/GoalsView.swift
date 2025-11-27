//
//  GoalsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var goalViewModel = GoalViewModel()
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationStack {
            List {
                if goalViewModel.goals.isEmpty {
                    EmptyGoalsView()
                } else {
                    ForEach(goalViewModel.goals) { goal in
                        GoalRowView(
                            goal: goal,
                            goalViewModel: goalViewModel
                        )
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            goalViewModel.deleteGoal(goalViewModel.goals[index])
                        }
                    }
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goalViewModel: goalViewModel)
            }
        }
    }
}

struct GoalRowView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    let goal: GoalEntity
    @ObservedObject var goalViewModel: GoalViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name ?? "Unknown Goal")
                        .font(.headline)
                    
                    if let deadline = goal.deadline {
                        let daysRemaining = goalViewModel.getDaysRemaining(for: goal)
                        Text("Deadline: \(deadline.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Days remaining: \(daysRemaining)")
                            .font(.caption)
                            .foregroundColor(daysRemaining < 30 ? .red : .secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(goal.currentAmount))
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("of \(formatCurrency(goal.targetAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    let progress = goalViewModel.getProgress(for: goal)
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Progress bar
            let progress = goalViewModel.getProgress(for: goal)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyFormatter.format(amount, currencyCode: currencyCode)
    }
}

struct EmptyGoalsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No goals set")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap + to create your first goal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var goalViewModel: GoalViewModel
    
    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var deadline: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Name") {
                    TextField("Goal name", text: $name)
                }
                
                Section("Target Amount") {
                    TextField("0.00", text: $targetAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Deadline") {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard !name.isEmpty,
              let amountValue = Double(targetAmount),
              amountValue > 0 else {
            return false
        }
        return true
    }
    
    private func saveGoal() {
        guard let amountValue = Double(targetAmount) else { return }
        
        goalViewModel.addGoal(
            name: name,
            targetAmount: amountValue,
            deadline: deadline
        )
        
        dismiss()
    }
}

#Preview {
    GoalsView()
}

