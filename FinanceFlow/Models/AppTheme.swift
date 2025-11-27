//
//  AppTheme.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import SwiftUI
import Combine

struct AppTheme: Identifiable, Codable {
    let id: UUID
    let name: String
    let primaryColorHex: String
    let secondaryColorHex: String
    let backgroundColorHex: String
    let accentColorHex: String
    
    var primaryColor: Color {
        Color.fromHex(primaryColorHex)
    }
    
    var secondaryColor: Color {
        Color.fromHex(secondaryColorHex)
    }
    
    var backgroundColor: Color {
        Color.fromHex(backgroundColorHex)
    }
    
    var accentColor: Color {
        Color.fromHex(accentColorHex)
    }
    
    static let defaultThemes: [AppTheme] = [
        AppTheme(
            id: UUID(),
            name: "Ocean",
            primaryColorHex: "#0066CC",
            secondaryColorHex: "#00CCFF",
            backgroundColorHex: "#F0F8FF",
            accentColorHex: "#0066CC"
        ),
        AppTheme(
            id: UUID(),
            name: "Forest",
            primaryColorHex: "#2E7D32",
            secondaryColorHex: "#66BB6A",
            backgroundColorHex: "#F1F8E9",
            accentColorHex: "#2E7D32"
        ),
        AppTheme(
            id: UUID(),
            name: "Sunset",
            primaryColorHex: "#FF6B35",
            secondaryColorHex: "#F7931E",
            backgroundColorHex: "#FFF3E0",
            accentColorHex: "#FF6B35"
        ),
        AppTheme(
            id: UUID(),
            name: "Purple",
            primaryColorHex: "#7B1FA2",
            secondaryColorHex: "#BA68C8",
            backgroundColorHex: "#F3E5F5",
            accentColorHex: "#7B1FA2"
        ),
        AppTheme(
            id: UUID(),
            name: "Midnight",
            primaryColorHex: "#1A237E",
            secondaryColorHex: "#3F51B5",
            backgroundColorHex: "#E8EAF6",
            accentColorHex: "#1A237E"
        )
    ]
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = AppTheme.defaultThemes[0]
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ""
    
    init() {
        loadTheme()
    }
    
    func applyTheme(_ theme: AppTheme) {
        currentTheme = theme
        selectedThemeId = theme.id.uuidString
    }
    
    private func loadTheme() {
        if let themeId = UUID(uuidString: selectedThemeId),
           let theme = AppTheme.defaultThemes.first(where: { $0.id == themeId }) {
            currentTheme = theme
        }
    }
}


