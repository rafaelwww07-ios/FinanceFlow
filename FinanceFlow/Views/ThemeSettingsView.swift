//
//  ThemeSettingsView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct ThemeSettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("selectedTheme") private var selectedTheme: String = "system"
    @AppStorage("accentColor") private var accentColorHex: String = "#007AFF"
    
    let themes = ["system", "light", "dark"]
    let accentColors: [(name: String, color: Color)] = [
        ("Blue", .blue),
        ("Green", .green),
        ("Purple", .purple),
        ("Orange", .orange),
        ("Pink", .pink),
        ("Red", .red),
        ("Teal", .teal),
        ("Indigo", .indigo)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }
                
                Section("Accent Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(accentColors, id: \.name) { colorOption in
                            Button {
                                accentColorHex = colorOption.color.toHex()
                            } label: {
                                Circle()
                                    .fill(colorOption.color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: accentColorHex == colorOption.color.toHex() ? 3 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("App Themes") {
                    ForEach(AppTheme.defaultThemes) { theme in
                        Button {
                            themeManager.applyTheme(theme)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [theme.primaryColor, theme.secondaryColor],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 30, height: 30)
                                
                                Text(theme.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if themeManager.currentTheme.id == theme.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Preview") {
                    HStack {
                        Text("Sample Card")
                            .font(.headline)
                        Spacer()
                        Text("$1,250.50")
                            .font(.headline)
                            .foregroundColor(Color.fromHex(accentColorHex))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .navigationTitle("Appearance")
        }
    }
}

