//
//  TagViewModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
class TagViewModel: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var tags: [TagEntity] = []
    @Published var isLoading = false
    
    init() {
        fetchTags()
    }
    
    func fetchTags() {
        isLoading = true
        let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TagEntity.name, ascending: true)]
        
        do {
            tags = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch tags: \(error)")
        }
        isLoading = false
    }
    
    func addTag(
        name: String,
        color: Color
    ) {
        let tag = TagEntity(context: viewContext)
        tag.id = UUID()
        tag.name = name
        tag.colorHex = color.toHex()
        
        persistenceController.save()
        fetchTags()
    }
    
    func updateTag(
        _ tag: TagEntity,
        name: String,
        color: Color
    ) {
        tag.name = name
        tag.colorHex = color.toHex()
        
        persistenceController.save()
        fetchTags()
    }
    
    func deleteTag(_ tag: TagEntity) {
        viewContext.delete(tag)
        persistenceController.save()
        fetchTags()
    }
}



