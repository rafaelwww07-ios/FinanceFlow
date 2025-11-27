//
//  GoalViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class GoalViewModel: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var goals: [GoalEntity] = []
    @Published var isLoading = false
    
    init() {
        fetchGoals()
    }
    
    func fetchGoals() {
        isLoading = true
        let request: NSFetchRequest<GoalEntity> = GoalEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GoalEntity.deadline, ascending: true)]
        
        do {
            goals = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch goals: \(error)")
        }
        isLoading = false
    }
    
    func addGoal(
        name: String,
        targetAmount: Double,
        deadline: Date
    ) {
        let goal = GoalEntity(context: viewContext)
        goal.id = UUID()
        goal.name = name
        goal.targetAmount = targetAmount
        goal.currentAmount = 0
        goal.deadline = deadline
        
        persistenceController.save()
        fetchGoals()
    }
    
    func updateGoal(
        _ goal: GoalEntity,
        name: String,
        targetAmount: Double,
        deadline: Date
    ) {
        goal.name = name
        goal.targetAmount = targetAmount
        goal.deadline = deadline
        
        persistenceController.save()
        fetchGoals()
    }
    
    func addAmountToGoal(_ goal: GoalEntity, amount: Double) {
        goal.currentAmount = min(goal.currentAmount + amount, goal.targetAmount)
        persistenceController.save()
        fetchGoals()
    }
    
    func deleteGoal(_ goal: GoalEntity) {
        viewContext.delete(goal)
        persistenceController.save()
        fetchGoals()
    }
    
    func getProgress(for goal: GoalEntity) -> Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.currentAmount / goal.targetAmount, 1.0)
    }
    
    func getDaysRemaining(for goal: GoalEntity) -> Int {
        guard let deadline = goal.deadline else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: deadline)
        return components.day ?? 0
    }
}



