//
//  SubcategoryModel.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import SwiftUI

struct SubcategoryModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    
    var color: Color {
        Color.fromHex(colorHex)
    }
    
    init(id: UUID = UUID(), name: String, icon: String, colorHex: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
}



