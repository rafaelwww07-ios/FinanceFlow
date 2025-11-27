//
//  CategoryViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class CategoryViewModel: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var categories: [CategoryEntity] = []
    @Published var isLoading = false
    
    init() {
        fetchCategories()
    }
    
    func fetchCategories() {
        isLoading = true
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CategoryEntity.isDefault, ascending: false),
            NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)
        ]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
        }
        isLoading = false
    }
    
    func getCategories(for type: TransactionType) -> [CategoryEntity] {
        categories.filter { $0.transactionType == type.rawValue }
    }
    
    func addCategory(
        name: String,
        icon: String,
        color: Color,
        transactionType: TransactionType
    ) {
        let category = CategoryEntity(context: viewContext)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.colorHex = color.toHex()
        category.isDefault = false
        category.transactionType = transactionType.rawValue
        
        persistenceController.save()
        fetchCategories()
    }
    
    func updateCategory(
        _ category: CategoryEntity,
        name: String,
        icon: String,
        color: Color
    ) {
        category.name = name
        category.icon = icon
        category.colorHex = color.toHex()
        
        persistenceController.save()
        fetchCategories()
    }
    
    func deleteCategory(_ category: CategoryEntity) {
        // Don't allow deleting default categories
        guard !category.isDefault else { return }
        
        viewContext.delete(category)
        persistenceController.save()
        fetchCategories()
    }
}

