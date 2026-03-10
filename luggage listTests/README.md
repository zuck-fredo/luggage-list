# Luggage List 🧳

A modern iOS app to organize packing for trips. Create trips, add items organized by category, and track your packing progress with smart reminders.

![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-6.0-blue)
![SwiftData](https://img.shields.io/badge/SwiftData-2.0-purple)

## Features

✅ **Trip Management** — Organize packing lists by trip with destinations and departure dates  
✅ **Category Organization** — Items grouped by clothing, toiletries, electronics, documents, accessories  
✅ **Packing Templates** — Quick-start with pre-built lists (Beach, Business, City Break, Hiking)  
✅ **Progress Tracking** — Visual progress bars show packing completion  
✅ **Smart Reminders** — Get notified the evening before and morning of departure  
✅ **Search** — Quickly find items in your packing list  
✅ **Clean Design** — Native SwiftUI with SF Symbols and smooth animations

## Screenshots

*Coming soon*

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

## Architecture

- **SwiftUI** for declarative UI
- **SwiftData** for persistent storage with relationships
- **UserNotifications** for departure reminders
- **Swift Testing** framework for unit tests

## Data Model

```swift
@Model
class Trip {
    var name: String
    var destination: String
    var departureDate: Date
    var items: [PackingItem]  // Cascade delete relationship
}

@Model
class PackingItem {
    var name: String
    var category: PackingCategory
    var isPacked: Bool
    var trip: Trip?
}

enum PackingCategory {
    case clothing, toiletries, electronics, documents, accessories, other
}
```

## Installation

1. Clone this repository
2. Open `luggage list.xcodeproj` in Xcode
3. Build and run on simulator or device

```bash
git clone https://github.com/YOUR_USERNAME/luggage-list.git
cd luggage-list
open "luggage list.xcodeproj"
```

## Usage

### Creating a Trip
1. Tap the **+** button
2. Enter trip name, destination, and departure date
3. Choose a packing template or start with an empty list
4. Enable reminders (optional)

### Adding Items
1. Open a trip
2. Tap **+** to add items
3. Enter item name and select category
4. Tap checkmark to mark items as packed

### Managing Packing
- ✅ Tap the circle icon to toggle packed status
- 🔍 Use search to find specific items
- 🗑️ Swipe left to delete items or trips
- 📦 Use "Unpack All" to reset for return journey

## Project Structure

```
luggage list/
├── Models/
│   ├── Item 3.swift          # Trip, PackingItem, PackingCategory models
│   └── TripNotificationManager.swift
├── Views/
│   ├── ContentView 3.swift   # Root view
│   ├── TripListView.swift    # List of all trips
│   ├── TripDetailView.swift  # Trip detail with items
│   └── AddTripView.swift     # New trip form
├── App/
│   └── luggage_listApp.swift
└── Tests/
    └── luggage_listTests.swift
```

## Known Issues

⚠️ **Work in Progress** — The project currently has duplicate model files causing compilation errors. These will be cleaned up soon:
- Multiple `Item.swift` files
- Multiple `ContentView.swift` files
- Duplicate view declarations

See `claude.md` for full documentation and cleanup plan.

## Roadmap

- [ ] Trip editing
- [ ] Item quantity support
- [ ] Custom templates
- [ ] Sharing packing lists
- [ ] Widget support
- [ ] iPad/Mac support
- [ ] iCloud sync
- [ ] Export/import lists

## Contributing

This is a personal project, but suggestions and feedback are welcome! Feel free to open an issue.

## Author

**Francesco Zucchetta**  
Created: February 2026

## License

This project is open source. Feel free to use and modify as you wish.

---

*Built with ❤️ using SwiftUI and SwiftData*
