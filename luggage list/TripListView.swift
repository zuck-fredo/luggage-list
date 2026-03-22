//
//  TripListView.swift
//  packing list
//

import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.departureDate) private var trips: [Trip]

    @State private var showingAddTrip = false

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    ContentUnavailableView(
                        "No trips yet",
                        systemImage: "airplane.departure",
                        description: Text("Tap + to plan your first trip.")
                    )
                } else {
                    List {
                        ForEach(trips) { trip in
                            NavigationLink(destination: TripDetailView(trip: trip)) {
                                TripRow(trip: trip)
                            }
                        }
                        .onDelete(perform: deleteTrips)
                    }
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton().disabled(trips.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        Label("Add Trip", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView()
            }
        }
    }

    private func deleteTrips(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let trip = trips[index]
                Task { await TripNotificationManager.shared.cancelReminders(for: trip) }
                modelContext.delete(trip)
            }
        }
    }
}

// MARK: - Trip Row

struct TripRow: View {
    let trip: Trip

    private var daysUntil: Int? {
        let days = Calendar.current.dateComponents([.day], from: .now, to: trip.departureDate).day ?? 0
        return days >= 0 ? days : nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(trip.name)
                    .font(.headline)
                Spacer()
                if let days = daysUntil {
                    Text(days == 0 ? "Today!" : "in \(days)d")
                        .font(.caption)
                        .foregroundStyle(days <= 1 ? .red : .secondary)
                } else {
                    Text("Past")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            if !trip.destination.isEmpty {
                Label(trip.destination, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(trip.departureDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !trip.items.isEmpty {
                    PackingProgressView(progress: trip.progress, packed: trip.packedCount, total: trip.items.count)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Packing Progress View

struct PackingProgressView: View {
    let progress: Double
    let packed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ProgressView(value: progress)
                .frame(width: 80)
                .tint(progress == 1 ? .green : .blue)
            Text("\(packed)/\(total)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
