//
//  ContentView.swift
//  packing list
//
//  Created by Francesco Zucchetta on 11/02/26.
//

import SwiftUI
import SwiftData

// MARK: - Home View

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Packing Lists Card
                NavigationLink(destination: PackingListView()) {
                    HomeCardView(
                        title: "Packing Lists",
                        icon: "suitcase.fill",
                        color: .blue
                    )
                }
                .buttonStyle(.plain)
                
                // Trip Planning Lists Card
                NavigationLink(destination: TripListView()) {
                    HomeCardView(
                        title: "Trip Planning Lists",
                        icon: "airplane.departure",
                        color: .purple
                    )
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Packing & Travel")
        }
    }
}

// MARK: - Home Card View

struct HomeCardView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(color)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Packing List View

struct PackingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingItem.name) private var items: [PackingItem]

    @State private var showingAddItem = false
    @State private var searchText = ""

    private var filteredItems: [PackingItem] {
        if searchText.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedItems: [(PackingCategory, [PackingItem])] {
        let grouped = Dictionary(grouping: filteredItems, by: \.category)
        return PackingCategory.allCases.compactMap { category in
            guard let categoryItems = grouped[category], !categoryItems.isEmpty else { return nil }
            return (category, categoryItems)
        }
    }

    private var packedCount: Int { items.filter(\.isPacked).count }

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView(
                    "Your bag is empty",
                    systemImage: "suitcase",
                    description: Text("Tap the + button to add items to pack.")
                )
            } else {
                List {
                    ForEach(groupedItems, id: \.0) { category, categoryItems in
                        Section {
                            ForEach(categoryItems) { item in
                                PackingItemRow(item: item)
                            }
                            .onDelete { offsets in
                                deleteItems(categoryItems, offsets: offsets)
                            }
                        } header: {
                            Label(category.rawValue, systemImage: category.symbol)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search items")
            }
        }
        .navigationTitle("Packing List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .disabled(items.isEmpty)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if !items.isEmpty {
                    Text("\(packedCount) of \(items.count) packed")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Unpack All", role: .destructive) {
                        unpackAll()
                    }
                    .disabled(packedCount == 0)
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView()
        }
    }

    private func deleteItems(_ categoryItems: [PackingItem], offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(categoryItems[index])
            }
        }
    }

    private func unpackAll() {
        withAnimation {
            items.forEach { $0.isPacked = false }
        }
    }
}

// MARK: - Packing Item Row

struct PackingItemRow: View {
    @Bindable var item: PackingItem

    var body: some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    item.isPacked.toggle()
                }
            } label: {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isPacked ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.name)
                .strikethrough(item.isPacked, color: .secondary)
                .foregroundStyle(item.isPacked ? .secondary : .primary)
                .animation(.default, value: item.isPacked)
        }
    }
}

// MARK: - Add Item View

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: PackingCategory = .clothing

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(PackingCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.symbol).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        withAnimation {
            let newItem = PackingItem(name: trimmedName, category: category)
            modelContext.insert(newItem)
        }
        dismiss()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PackingList.self, inMemory: true)
}
