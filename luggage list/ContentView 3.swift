//
//  ContentView.swift
//  luggage list
//
//  Created by Francesco Zucchetta on 11/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TripListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Trip.self, PackingItem.self], inMemory: true)
}
