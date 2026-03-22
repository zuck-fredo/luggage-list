//
//  Item.swift
//  luggage list
//
//  Created by Francesco Zucchetta on 11/02/26.
//

import Foundation
import SwiftData

// MARK: - Category

enum PackingCategory: String, CaseIterable, Codable {
    case clothing    = "Clothing"
    case toiletries  = "Toiletries"
    case electronics = "Electronics"
    case documents   = "Documents"
    case accessories = "Accessories"
    case other       = "Other"

    var symbol: String {
        switch self {
        case .clothing:     return "tshirt"
        case .toiletries:   return "shower"
        case .electronics:  return "laptopcomputer"
        case .documents:    return "doc.text"
        case .accessories:  return "bag"
        case .other:        return "ellipsis.circle"
        }
    }
}

// MARK: - Packing List

@Model
final class PackingList {
    var name: String
    var createdDate: Date
    @Relationship(deleteRule: .cascade, inverse: \PackingItem.packingList)
    var items: [PackingItem]
    
    var packedCount: Int { items.filter(\.isPacked).count }
    var progress: Double {
        items.isEmpty ? 0 : Double(packedCount) / Double(items.count)
    }
    
    init(name: String, createdDate: Date = .now) {
        self.name = name
        self.createdDate = createdDate
        self.items = []
    }
}

// MARK: - Packing Item

@Model
final class PackingItem {
    var name: String
    var category: PackingCategory
    var isPacked: Bool
    var trip: Trip?
    var packingList: PackingList?

    init(name: String, category: PackingCategory = .other, isPacked: Bool = false) {
        self.name = name
        self.category = category
        self.isPacked = isPacked
    }
}

// MARK: - Trip

@Model
final class Trip {
    var name: String
    var destination: String
    var departureDate: Date
    @Relationship(deleteRule: .cascade, inverse: \PackingItem.trip)
    var items: [PackingItem]

    var packedCount: Int { items.filter(\.isPacked).count }
    var progress: Double {
        items.isEmpty ? 0 : Double(packedCount) / Double(items.count)
    }

    init(name: String, destination: String = "", departureDate: Date = .now) {
        self.name = name
        self.destination = destination
        self.departureDate = departureDate
        self.items = []
    }
}

// MARK: - Packing Templates

struct PackingTemplate {
    let name: String
    let items: [(name: String, category: PackingCategory)]

    static let beach = PackingTemplate(name: "🏖️ Beach", items: [
        ("Swimsuit", .clothing), ("Sunscreen", .toiletries), ("Sunglasses", .accessories),
        ("Beach towel", .accessories), ("Flip flops", .clothing), ("Passport", .documents),
        ("Phone charger", .electronics), ("Camera", .electronics)
    ])

    static let business = PackingTemplate(name: "💼 Business", items: [
        ("Suit", .clothing), ("Dress shirt", .clothing), ("Laptop", .electronics),
        ("Laptop charger", .electronics), ("Business cards", .documents),
        ("Passport", .documents), ("Notebook", .accessories), ("Toothbrush", .toiletries)
    ])

    static let cityBreak = PackingTemplate(name: "🏙️ City Break", items: [
        ("Jeans", .clothing), ("T-shirts", .clothing), ("Comfortable shoes", .clothing),
        ("Toothbrush", .toiletries), ("Shampoo", .toiletries), ("Phone charger", .electronics),
        ("Earphones", .electronics), ("Wallet", .accessories), ("Passport", .documents)
    ])

    static let hiking = PackingTemplate(name: "🥾 Hiking", items: [
        ("Hiking boots", .clothing), ("Moisture-wicking shirts", .clothing),
        ("Rain jacket", .clothing), ("Sunscreen", .toiletries), ("First aid kit", .accessories),
        ("Water bottle", .accessories), ("Trail map", .documents), ("Headlamp", .electronics),
        ("Power bank", .electronics)
    ])

    static let all: [PackingTemplate] = [.beach, .business, .cityBreak, .hiking]
}
