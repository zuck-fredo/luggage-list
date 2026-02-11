//
//  Item.swift
//  luggage list
//
//  Created by Francesco Zucchetta on 11/02/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
