//
//  TripNotificationManager.swift
//  packing list
//

import Foundation
import SwiftData
import UserNotifications

@MainActor
final class TripNotificationManager {
    static let shared = TripNotificationManager()
    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule

    /// Schedules a reminder 1 day before departure and one on the morning of departure.
    func scheduleReminders(for trip: Trip) async {
        await cancelReminders(for: trip)

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let tripName = trip.name
        let tripID = trip.persistentModelID.hashValue

        // 1 day before at 20:00
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: trip.departureDate)
        if let dayBefore, dayBefore > .now {
            schedule(
                id: "\(tripID)-dayBefore",
                title: "✈️ \(tripName) is tomorrow!",
                body: "\(trip.packedCount) of \(trip.items.count) items packed. Time to finish up!",
                date: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: dayBefore) ?? dayBefore
            )
        }

        // Morning of departure at 07:00
        let morning = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: trip.departureDate) ?? trip.departureDate
        if morning > .now {
            schedule(
                id: "\(tripID)-departure",
                title: "🧳 Time to go — \(tripName)!",
                body: trip.packedCount == trip.items.count
                    ? "Everything is packed. Have a great trip!"
                    : "\(trip.items.count - trip.packedCount) items still unpacked. Check your list!",
                date: morning
            )
        }
    }

    func cancelReminders(for trip: Trip) async {
        let tripID = trip.persistentModelID.hashValue
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["\(tripID)-dayBefore", "\(tripID)-departure"]
        )
    }

    // MARK: - Private

    private func schedule(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
