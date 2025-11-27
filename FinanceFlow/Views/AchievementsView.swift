//
//  AchievementsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct AchievementsView: View {
    private let achievementService = AchievementService.shared
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var goalViewModel = GoalViewModel()
    @StateObject private var budgetViewModel: BudgetViewModel
    
    init() {
        let transactionVM = TransactionViewModel()
        _transactionViewModel = StateObject(wrappedValue: transactionVM)
        _budgetViewModel = StateObject(wrappedValue: BudgetViewModel(transactionViewModel: transactionVM))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Summary
                    let unlockedCount = achievementService.achievements.filter { $0.isUnlocked }.count
                    let totalCount = achievementService.achievements.count
                    let progress = Double(unlockedCount) / Double(totalCount)
                    
                    VStack(spacing: 12) {
                        Text("Achievements")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(unlockedCount) of \(totalCount) unlocked")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .frame(height: 8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    // Achievements Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(achievementService.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .onAppear {
                achievementService.checkAchievements(
                    transactions: transactionViewModel.transactions,
                    goals: goalViewModel.goals,
                    budgets: budgetViewModel.budgets
                )
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(achievement.isUnlocked ? achievement.color.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? achievement.color : Color.clear, lineWidth: 2)
        )
    }
}


