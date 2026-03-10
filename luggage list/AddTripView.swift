//
//  AddTripView.swift
//  luggage list
//

import SwiftUI
import SwiftData

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var tripName = ""
    @State private var destination = ""
    @State private var departureDate = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var selectedTemplate: PackingTemplate? = nil
    @State private var notificationsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip name (e.g. Summer Holiday)", text: $tripName)
                    TextField("Destination (optional)", text: $destination)
                    DatePicker("Departure", selection: $departureDate, in: Date.now..., displayedComponents: .date)
                }

                Section {
                    Toggle("Departure reminders", isOn: $notificationsEnabled)
                } footer: {
                    Text("You'll be reminded the evening before and on the morning of your trip.")
                }

                Section("Start from a template") {
                    // No template option
                    HStack {
                        Image(systemName: selectedTemplate == nil ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedTemplate == nil ? .blue : .secondary)
                        Text("Empty list")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTemplate = nil }

                    ForEach(PackingTemplate.all, id: \.name) { template in
                        HStack {
                            Image(systemName: selectedTemplate?.name == template.name ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedTemplate?.name == template.name ? .blue : .secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.name)
                                Text("\(template.items.count) items")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { selectedTemplate = template }
                    }
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createTrip() }
                        .disabled(tripName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func createTrip() {
        let name = tripName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let trip = Trip(
            name: name,
            destination: destination.trimmingCharacters(in: .whitespaces),
            departureDate: departureDate
        )
        modelContext.insert(trip)

        if let template = selectedTemplate {
            for itemData in template.items {
                let item = PackingItem(name: itemData.name, category: itemData.category)
                item.trip = trip
                modelContext.insert(item)
            }
        }

        if notificationsEnabled {
            Task {
                let granted = await TripNotificationManager.shared.requestAuthorization()
                if granted {
                    await TripNotificationManager.shared.scheduleReminders(for: trip)
                }
            }
        }

        dismiss()
    }
}
