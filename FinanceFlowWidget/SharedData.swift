//
//  SharedData.swift
//  FinanceFlowWidget
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import CoreData

// Общий доступ к Core Data для виджетов
class SharedPersistenceController {
    static let shared = SharedPersistenceController()
    
    private let appGroupIdentifier = "group.com.financeflow.app"
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FinanceFlowModel")
        
        guard let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            fatalError("Unable to access App Group container")
        }
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL.appendingPathComponent("FinanceFlowModel.sqlite"))
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load in widget: \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    private init() {}
}


