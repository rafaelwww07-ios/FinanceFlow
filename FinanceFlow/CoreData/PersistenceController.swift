//
//  PersistenceController.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import CoreData
import Foundation
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    
    // App Group для доступа из виджетов
    static let appGroupIdentifier = "group.com.financeflow.app"
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample categories
        let category1 = CategoryEntity(context: viewContext)
        category1.id = UUID()
        category1.name = "Food"
        category1.icon = "fork.knife"
        category1.colorHex = Color.orange.toHex()
        category1.isDefault = true
        category1.transactionType = TransactionType.expense.rawValue
        
        let category2 = CategoryEntity(context: viewContext)
        category2.id = UUID()
        category2.name = "Salary"
        category2.icon = "dollarsign.circle.fill"
        category2.colorHex = Color.green.toHex()
        category2.isDefault = true
        category2.transactionType = TransactionType.income.rawValue
        
        // Create sample transactions
        let transaction1 = TransactionEntity(context: viewContext)
        transaction1.id = UUID()
        transaction1.amount = 50.0
        transaction1.date = Date()
        transaction1.note = "Lunch"
        transaction1.type = TransactionType.expense.rawValue
        transaction1.category = category1
        
        let transaction2 = TransactionEntity(context: viewContext)
        transaction2.id = UUID()
        transaction2.amount = 5000.0
        transaction2.date = Date().addingTimeInterval(-86400)
        transaction2.note = "Monthly salary"
        transaction2.type = TransactionType.income.rawValue
        transaction2.category = category2
        
        try? viewContext.save()
        return controller
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FinanceFlowModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Настройка для App Group (для виджетов)
            if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PersistenceController.appGroupIdentifier) {
                let storeDescription = NSPersistentStoreDescription(url: storeURL.appendingPathComponent("FinanceFlowModel.sqlite"))
                container.persistentStoreDescriptions = [storeDescription]
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Initialize default categories if needed
        initializeDefaultCategories()
    }
    
    private func initializeDefaultCategories() {
        let context = container.viewContext
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                // Add default categories
                for category in CategoryModel.defaultCategories {
                    let entity = CategoryEntity(context: context)
                    entity.id = UUID()
                    entity.name = category.name
                    entity.icon = category.icon
                    entity.colorHex = category.color.toHex()
                    entity.isDefault = category.isDefault
                    entity.transactionType = category.transactionType.rawValue
                }
                try context.save()
            }
        } catch {
            print("Failed to initialize default categories: \(error)")
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

// Helper extension for Color to Hex conversion
import UIKit

extension Color {
    func toHex() -> String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
        #else
        return "#000000"
        #endif
    }
    
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return Color.gray
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

