//
//  TemplateViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class TemplateViewModel: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var templates: [TransactionTemplateEntity] = []
    @Published var isLoading = false
    
    init() {
        fetchTemplates()
    }
    
    func fetchTemplates() {
        isLoading = true
        let request: NSFetchRequest<TransactionTemplateEntity> = TransactionTemplateEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionTemplateEntity.name, ascending: true)]
        
        do {
            templates = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch templates: \(error)")
        }
        isLoading = false
    }
    
    func addTemplate(
        name: String,
        amount: Double,
        type: TransactionType,
        category: CategoryEntity,
        note: String?
    ) {
        let template = TransactionTemplateEntity(context: viewContext)
        template.id = UUID()
        template.name = name
        template.amount = amount
        template.type = type.rawValue
        template.category = category
        template.note = note
        
        persistenceController.save()
        fetchTemplates()
    }
    
    func updateTemplate(
        _ template: TransactionTemplateEntity,
        name: String,
        amount: Double,
        type: TransactionType,
        category: CategoryEntity,
        note: String?
    ) {
        template.name = name
        template.amount = amount
        template.type = type.rawValue
        template.category = category
        template.note = note
        
        persistenceController.save()
        fetchTemplates()
    }
    
    func deleteTemplate(_ template: TransactionTemplateEntity) {
        viewContext.delete(template)
        persistenceController.save()
        fetchTemplates()
    }
    
    func createTransaction(from template: TransactionTemplateEntity, date: Date = Date()) -> TransactionEntity {
        let transaction = TransactionEntity(context: viewContext)
        transaction.id = UUID()
        transaction.amount = template.amount
        transaction.type = template.type
        transaction.category = template.category
        transaction.date = date
        transaction.note = template.note
        transaction.template = template
        
        return transaction
    }
}



