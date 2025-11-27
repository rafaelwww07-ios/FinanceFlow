//
//  TagsManagementView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct TagsManagementView: View {
    @StateObject private var tagViewModel = TagViewModel()
    @State private var showingAddTag = false
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue,
        .indigo, .purple, .pink, .brown, .gray
    ]
    
    var body: some View {
        List {
            if tagViewModel.tags.isEmpty {
                EmptyTagsView()
            } else {
                ForEach(tagViewModel.tags) { tag in
                    TagRowView(tag: tag)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        tagViewModel.deleteTag(tagViewModel.tags[index])
                    }
                }
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTag = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddTag) {
            AddTagView(tagViewModel: tagViewModel, colors: colors)
        }
    }
}

struct TagRowView: View {
    let tag: TagEntity
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.fromHex(tag.colorHex ?? "#000000"))
                .frame(width: 20, height: 20)
            
            Text(tag.name ?? "Unknown")
                .font(.headline)
            
            Spacer()
            
            Text("\(tag.transactions?.count ?? 0) transactions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyTagsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tag")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No tags")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Create tags to organize your transactions")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AddTagView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var tagViewModel: TagViewModel
    let colors: [Color]
    
    @State private var name: String = ""
    @State private var selectedColor: Color = .blue
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tag Name") {
                    TextField("Tag name", text: $name)
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
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTag()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveTag() {
        tagViewModel.addTag(
            name: name,
            color: selectedColor
        )
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TagsManagementView()
    }
}



