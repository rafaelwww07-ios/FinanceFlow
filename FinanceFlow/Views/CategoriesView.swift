//
//  CategoriesView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var categoryViewModel = CategoryViewModel()
    @State private var showingAddCategory = false
    @State private var editingCategory: CategoryEntity?
    @State private var selectedType: TransactionType = .expense
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type Picker
                Picker("Type", selection: $selectedType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.displayName)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Categories List
                List {
                    Section {
                        ForEach(categoryViewModel.getCategories(for: selectedType)) { category in
                            CategoryRowView(category: category)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if !category.isDefault {
                                        Button(role: .destructive) {
                                            categoryViewModel.deleteCategory(category)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            editingCategory = category
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                }
                                .onTapGesture {
                                    if !category.isDefault {
                                        editingCategory = category
                                    }
                                }
                        }
                    } header: {
                        Text("Categories")
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(
                    categoryViewModel: categoryViewModel,
                    transactionType: selectedType
                )
            }
            .sheet(item: $editingCategory) { category in
                EditCategoryView(
                    category: category,
                    categoryViewModel: categoryViewModel
                )
            }
        }
    }
}

struct CategoryRowView: View {
    let category: CategoryEntity
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.fromHex(category.colorHex ?? "#000000").opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: category.icon ?? "questionmark.circle")
                    .foregroundColor(Color.fromHex(category.colorHex ?? "#000000"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name ?? "Unknown")
                    .font(.headline)
                
                if category.isDefault {
                    Text("Default")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !category.isDefault {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var categoryViewModel: CategoryViewModel
    let transactionType: TransactionType
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColor: Color = .blue
    
    let icons = [
        "star.fill", "heart.fill", "house.fill", "car.fill", "airplane",
        "gamecontroller.fill", "book.fill", "music.note", "camera.fill",
        "gift.fill", "cart.fill", "creditcard.fill", "dollarsign.circle.fill"
    ]
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue,
        .indigo, .purple, .pink, .brown, .gray
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }
                
                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                                        .padding()
                                        .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        categoryViewModel.addCategory(
            name: name,
            icon: selectedIcon,
            color: selectedColor,
            transactionType: transactionType
        )
        dismiss()
    }
}

struct EditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    let category: CategoryEntity
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    
    let icons = [
        "star.fill", "heart.fill", "house.fill", "car.fill", "airplane",
        "gamecontroller.fill", "book.fill", "music.note", "camera.fill",
        "gift.fill", "cart.fill", "creditcard.fill", "dollarsign.circle.fill"
    ]
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue,
        .indigo, .purple, .pink, .brown, .gray
    ]
    
    init(category: CategoryEntity, categoryViewModel: CategoryViewModel) {
        self.category = category
        self.categoryViewModel = categoryViewModel
        
        _name = State(initialValue: category.name ?? "")
        _selectedIcon = State(initialValue: category.icon ?? "star.fill")
        _selectedColor = State(initialValue: Color.fromHex(category.colorHex ?? "#000000"))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }
                
                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                                        .padding()
                                        .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        categoryViewModel.updateCategory(
            category,
            name: name,
            icon: selectedIcon,
            color: selectedColor
        )
        dismiss()
    }
}

#Preview {
    CategoriesView()
}

