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

#Preview {
    ContentView()
        .modelContainer(for: PackingList.self, inMemory: true)
}
