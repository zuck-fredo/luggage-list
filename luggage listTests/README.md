# Packing & Travel 🧳✈️

A modern iOS app to organize packing and trip planning. The app features a home screen with two main sections: general packing lists organized by category, and trip-specific planning with destinations, dates, and smart reminders.

![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-6.0-blue)
![SwiftData](https://img.shields.io/badge/SwiftData-2.0-purple)

## Features

✅ **Home Screen** — Card-based navigation to Packing Lists and Trip Planning sections  
✅ **General Packing Lists** — Manage reusable packing items organized by category  
✅ **Trip Management** — Organize trip-specific packing lists with destinations and departure dates  
✅ **Category Organization** — Items grouped by clothing, toiletries, electronics, documents, accessories  
✅ **Packing Templates** — Quick-start with pre-built lists (Beach, Business, City Break, Hiking)  
✅ **Progress Tracking** — Visual progress bars show packing completion  
✅ **Smart Reminders** — Get notified the evening before and morning of departure  
✅ **Search** — Quickly find items in your packing lists  
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
2. Open `packing list.xcodeproj` in Xcode
3. Build and run on simulator or device

```bash
git clone https://github.com/YOUR_USERNAME/packing-list.git
cd packing-list
open "packing list.xcodeproj"
```

## Usage

### Home Screen
The app opens to a "Packing & Travel" home screen with two cards:
- **Packing Lists** — Manage general packing items (reusable across trips)
- **Trip Planning Lists** — Create and manage trip-specific planning

### Managing Packing Lists
1. Tap the **Packing Lists** card on the home screen
2. Tap **+** to add items to your general packing list
3. Enter item name and select category
4. Tap checkmark to mark items as packed
5. Use "Unpack All" to reset all items

### Creating a Trip
1. Tap the **Trip Planning Lists** card on the home screen
2. Tap the **+** button
3. Enter trip name, destination, and departure date
4. Choose a packing template or start with an empty list
5. Enable reminders (optional)

### Managing Trip Items
1. Open a trip from the Trip Planning Lists
2. Tap **+** to add items specific to this trip
3. Enter item name and select category
4. Tap checkmark to mark items as packed

### General Tips
- ✅ Tap the circle icon to toggle packed status
- 🔍 Use search to find specific items
- 🗑️ Swipe left to delete items or trips
- 📦 Use "Unpack All" to reset for return journey

## Project Structure

```
packing list/
├── Models/
│   ├── Item.swift                # Trip, PackingItem, PackingCategory models
│   └── TripNotificationManager.swift
├── Views/
│   ├── ContentView.swift         # Root view with packing list
│   ├── TripListView.swift        # List of all trips
│   ├── TripDetailView.swift      # Trip detail with items
│   └── AddTripView.swift         # New trip form
├── App/
│   └── packing_listApp.swift
└── Tests/
    └── packing_listTests.swift
```

## Status

✅ **Project Structure** — Code has been cleaned up and organized:
- Model files consolidated in `Item.swift`
- Views properly separated and named
- Test files updated with new naming

See `claude.md` for full documentation.

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
