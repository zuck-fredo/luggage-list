//
//  TripDetailView.swift
//  packing list
//

import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddItem = false
    @State private var searchText = ""

    private var filteredItems: [PackingItem] {
        if searchText.isEmpty { return trip.items }
        return trip.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedItems: [(PackingCategory, [PackingItem])] {
        let grouped = Dictionary(grouping: filteredItems, by: \.category)
        return PackingCategory.allCases.compactMap { category in
            guard let categoryItems = grouped[category], !categoryItems.isEmpty else { return nil }
            return (category, categoryItems.sorted { $0.name < $1.name })
        }
    }

    var body: some View {
        Group {
            if trip.items.isEmpty {
                ContentUnavailableView(
                    "Bag is empty",
                    systemImage: "suitcase",
                    description: Text("Tap + to add items to pack.")
                )
            } else {
                List {
                    ForEach(groupedItems, id: \.0) { category, categoryItems in
                        Section {
                            ForEach(categoryItems) { item in
                                TripItemRow(item: item)
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
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton().disabled(trip.items.isEmpty)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if !trip.items.isEmpty {
                    PackingProgressView(
                        progress: trip.progress,
                        packed: trip.packedCount,
                        total: trip.items.count
                    )
                    Spacer()
                    Button("Unpack All", role: .destructive) {
                        unpackAll()
                    }
                    .disabled(trip.packedCount == 0)
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddTripItemView(trip: trip)
        }
        .task {
            await TripNotificationManager.shared.scheduleReminders(for: trip)
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
            trip.items.forEach { $0.isPacked = false }
        }
    }
}

// MARK: - Trip Item Row

struct TripItemRow: View {
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

// MARK: - Add Trip Item View

struct AddTripItemView: View {
    let trip: Trip
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
                    Button("Add") { addItem() }
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
            newItem.trip = trip
            modelContext.insert(newItem)
        }
        dismiss()
    }
}
