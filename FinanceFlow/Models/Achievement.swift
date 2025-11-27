//
//  Achievement.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import SwiftUI

struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let colorHex: String
    let requirement: AchievementRequirement
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    var color: Color {
        Color.fromHex(colorHex)
    }
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, colorHex: String, requirement: AchievementRequirement, isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.colorHex = colorHex
        self.requirement = requirement
        self.isUnlocked = isUnlocked
    }
}

enum AchievementRequirement: Codable {
    case transactionsCount(Int)
    case totalSaved(Double)
    case streakDays(Int)
    case budgetMet(Int) // количество бюджетов, которые не превышены
    case categorySpending(String, Double) // категория и максимальная сумма
    case goalCompleted
}

class AchievementService {
    static let shared = AchievementService()
    
    private let achievementsKey = "achievements"
    
    private init() {
        initializeAchievements()
    }
    
    var achievements: [Achievement] {
        get {
            if let data = UserDefaults.standard.data(forKey: achievementsKey),
               let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
                return decoded
            }
            return defaultAchievements()
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: achievementsKey)
            }
        }
    }
    
    private func defaultAchievements() -> [Achievement] {
        return [
            Achievement(
                title: "First Step",
                description: "Add your first transaction",
                icon: "star.fill",
                colorHex: "#FFD700",
                requirement: .transactionsCount(1)
            ),
            Achievement(
                title: "Saver",
                description: "Save $1000",
                icon: "dollarsign.circle.fill",
                colorHex: "#00C853",
                requirement: .totalSaved(1000)
            ),
            Achievement(
                title: "Consistent",
                description: "Track expenses for 7 days",
                icon: "flame.fill",
                colorHex: "#FF6B00",
                requirement: .streakDays(7)
            ),
            Achievement(
                title: "Budget Master",
                description: "Stay within budget for 3 categories",
                icon: "target",
                colorHex: "#3F51B5",
                requirement: .budgetMet(3)
            ),
            Achievement(
                title: "Goal Achiever",
                description: "Complete your first goal",
                icon: "checkmark.circle.fill",
                colorHex: "#9C27B0",
                requirement: .goalCompleted
            )
        ]
    }
    
    func checkAchievements(transactions: [TransactionEntity], goals: [GoalEntity], budgets: [BudgetEntity]) {
        var updatedAchievements = achievements
        
        for (index, achievement) in updatedAchievements.enumerated() {
            if achievement.isUnlocked { continue }
            
            var isUnlocked = false
            
            switch achievement.requirement {
            case .transactionsCount(let count):
                isUnlocked = transactions.count >= count
                
            case .totalSaved(let amount):
                let totalIncome = transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
                let totalExpense = transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
                isUnlocked = (totalIncome - totalExpense) >= amount
                
            case .streakDays(let days):
                // Упрощенная проверка - в реальном приложении нужно отслеживать streak
                isUnlocked = transactions.count >= days
                
            case .budgetMet(let count):
                // Для проверки достижений нужно передать transactionViewModel
                // Временно используем упрощенную проверку
                let metBudgets = budgets.filter { budget in
                    // Упрощенная проверка - в реальном приложении нужен BudgetViewModel
                    return true // Всегда true для упрощения
                }
                isUnlocked = metBudgets.count >= count
                
            case .categorySpending(_, _):
                // Реализация для конкретной категории
                break
                
            case .goalCompleted:
                isUnlocked = goals.contains { $0.currentAmount >= $0.targetAmount }
            }
            
            if isUnlocked {
                updatedAchievements[index].isUnlocked = true
                updatedAchievements[index].unlockedDate = Date()
            }
        }
        
        achievements = updatedAchievements
    }
    
    private func initializeAchievements() {
        if UserDefaults.standard.data(forKey: achievementsKey) == nil {
            achievements = defaultAchievements()
        }
    }
}


