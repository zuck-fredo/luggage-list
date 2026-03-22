//
//  PackingListView.swift
//  packing list
//
//  Created by Francesco Zucchetta on 11/02/26.
//

import SwiftUI
import SwiftData

// MARK: - Packing List View

struct PackingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingList.createdDate, order: .reverse) private var packingLists: [PackingList]
    
    @State private var showingAddList = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if packingLists.isEmpty {
                    ContentUnavailableView(
                        "No lists created yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Tap + to create a new list!")
                    )
                } else {
                    List {
                        ForEach(packingLists) { list in
                            NavigationLink(destination: PackingListDetailView(packingList: list)) {
                                PackingListRow(packingList: list)
                            }
                        }
                        .onDelete(perform: deletePackingLists)
                    }
                }
            }
            
            // Floating Add Button
            Button {
                showingAddList = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue, in: Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Packing Lists")
        .sheet(isPresented: $showingAddList) {
            AddPackingListView()
        }
    }
    
    private func deletePackingLists(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(packingLists[index])
            }
        }
    }
}

// MARK: - Packing List Row

struct PackingListRow: View {
    let packingList: PackingList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(packingList.name)
                    .font(.headline)
                Spacer()
                if !packingList.items.isEmpty {
                    Text("\(packingList.packedCount)/\(packingList.items.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            
            if !packingList.items.isEmpty {
                HStack {
                    Text("\(packingList.items.count) items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    ProgressView(value: packingList.progress)
                        .frame(width: 80)
                        .tint(packingList.progress == 1 ? .green : .blue)
                }
            } else {
                Text("No items")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Packing List View

struct AddPackingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("List Details") {
                    TextField("List name", text: $name)
                }
            }
            .navigationTitle("New Packing List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createPackingList()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func createPackingList() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        withAnimation {
            let newList = PackingList(name: trimmedName)
            modelContext.insert(newList)
        }
        dismiss()
    }
}

// MARK: - Packing List Detail View

struct PackingListDetailView: View {
    @Bindable var packingList: PackingList
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddItem = false
    @State private var searchText = ""

    private var filteredItems: [PackingItem] {
        if searchText.isEmpty { return packingList.items }
        return packingList.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedItems: [(PackingCategory, [PackingItem])] {
        let grouped = Dictionary(grouping: filteredItems, by: \.category)
        return PackingCategory.allCases.compactMap { category in
            guard let categoryItems = grouped[category], !categoryItems.isEmpty else { return nil }
            return (category, categoryItems)
        }
    }

    private var packedCount: Int { packingList.items.filter(\.isPacked).count }

    var body: some View {
        Group {
            if packingList.items.isEmpty {
                ContentUnavailableView(
                    "No items yet",
                    systemImage: "suitcase",
                    description: Text("Tap the + button to add items to this list.")
                )
            } else {
                List {
                    ForEach(groupedItems, id: \.0) { category, categoryItems in
                        Section {
                            ForEach(categoryItems) { item in
                                PackingListItemRow(item: item)
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
        .navigationTitle(packingList.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .disabled(packingList.items.isEmpty)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if !packingList.items.isEmpty {
                    Text("\(packedCount) of \(packingList.items.count) packed")
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
            AddItemToPackingListView(packingList: packingList)
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
            packingList.items.forEach { $0.isPacked = false }
        }
    }
}

// MARK: - Packing List Item Row

struct PackingListItemRow: View {
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

// MARK: - Add Item to Packing List View

struct AddItemToPackingListView: View {
    let packingList: PackingList
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
            newItem.packingList = packingList
            modelContext.insert(newItem)
        }
        dismiss()
    }
}
