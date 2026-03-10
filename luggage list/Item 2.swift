//
//  Item.swift
//  luggage list
//
//  Created by Francesco Zucchetta on 11/02/26.
//

import Foundation
import SwiftData

enum PackingCategory: String, CaseIterable, Codable {
    case clothing = "Clothing"
    case toiletries = "Toiletries"
    case electronics = "Electronics"
    case documents = "Documents"
    case accessories = "Accessories"
    case other = "Other"

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

@Model
final class PackingItem {
    var name: String
    var category: PackingCategory
    var isPacked: Bool

    init(name: String, category: PackingCategory = .other, isPacked: Bool = false) {
        self.name = name
        self.category = category
        self.isPacked = isPacked
    }
}
