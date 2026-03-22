# Packing List — Project Documentation

**Author:** Francesco Zucchetta  
**Created:** February 11, 2026  
**Platform:** iOS (SwiftUI + SwiftData)

---

## Overview

Packing & Travel is an iOS app that helps users organize packing for trips. The app features a home screen with two main sections:

1. **Packing Lists** — General packing items organized by category (clothing, toiletries, electronics, etc.)
2. **Trip Planning Lists** — Trip-specific planning with destinations, dates, and per-trip packing items

Users can create trips, add packing items organized by category, and track their packing progress. The app includes notification reminders, packing templates, and a clean SwiftUI interface with card-based navigation.

---

## Architecture

### Technology Stack
- **SwiftUI** for the user interface
- **SwiftData** for persistent data storage
- **UserNotifications** for departure reminders
- **Swift Testing** framework for unit tests

### Design Patterns
- MVVM-style architecture with SwiftData models
- Observable `@Model` classes for automatic UI updates
- Environment-based dependency injection (`@Environment`, `@Query`)
- Sheet-based modal presentations for add/edit flows

---

## Data Models

The app uses SwiftData for persistence with the following models:

### `Trip` (Item.swift)
The main entity representing a planned trip.

**Properties:**
- `name: String` — Trip name (e.g., "Summer Holiday")
- `destination: String` — Where the user is going (optional)
- `departureDate: Date` — When the trip starts
- `items: [PackingItem]` — Packing items with cascade delete relationship

**Computed Properties:**
- `packedCount: Int` — Number of items marked as packed
- `progress: Double` — Packing completion (0.0 to 1.0)

**Relationships:**
- One-to-many with `PackingItem` (inverse: `\PackingItem.trip`)
- Delete rule: `.cascade` (deleting a trip deletes all its items)

---

### `PackingItem` (Item.swift)
Individual items to pack for a trip.

**Properties:**
- `name: String` — Item name (e.g., "Passport", "Sunglasses")
- `category: PackingCategory` — Item category (enum)
- `isPacked: Bool` — Whether the item is packed (default: false)
- `trip: Trip?` — Optional back-reference to parent trip

---

### `PackingCategory` (Item.swift)
Enum categorizing packing items.

**Cases:**
- `.clothing` — T-shirts, jeans, swimsuit, etc.
- `.toiletries` — Toothbrush, shampoo, sunscreen, etc.
- `.electronics` — Phone charger, laptop, camera, etc.
- `.documents` — Passport, tickets, etc.
- `.accessories` — Sunglasses, bag, wallet, etc.
- `.other` — Miscellaneous items

**Properties:**
- `symbol: String` — SF Symbol name for each category

**Conformances:**
- `String`, `CaseIterable`, `Codable`

---

### Legacy Model

**`Item` (Item.swift)** — Original template model with timestamp. **Not used in the app.** This is leftover from the Xcode project template and should be removed.

---

## Packing Templates

Pre-defined item lists for common trip types (Item.swift):

- **🏖️ Beach** — Swimsuit, sunscreen, flip flops, etc.
- **💼 Business** — Suit, laptop, business cards, etc.
- **🏙️ City Break** — Jeans, t-shirts, comfortable shoes, etc.
- **🥾 Hiking** — Hiking boots, rain jacket, first aid kit, etc.

Templates are used when creating a new trip to quickly populate items.

---

## Views & Navigation

### Navigation Hierarchy

```
ContentView (ContentView.swift) — "Packing & Travel" Home Screen
  │
  ├─ HomeCardView → NavigationLink to PackingListView
  │    └─ PackingListView (ContentView.swift)
  │         ├─ Grouped by PackingCategory
  │         ├─ PackingItemRow (inline component)
  │         └─ AddItemView (sheet for adding new items)
  │
  └─ HomeCardView → NavigationLink to TripListView
       └─ TripListView (TripListView.swift)
            ├─ TripDetailView (TripDetailView.swift) [NavigationLink]
            │    ├─ PackingItemRow (inline)
            │    └─ AddItemView (sheet)
            └─ AddTripView (AddTripView.swift) [sheet]
```

---

### Key Views

#### **ContentView** (ContentView.swift)
Home screen titled "Packing & Travel" with two navigation cards:
- **Packing Lists** card (blue, suitcase icon)
- **Trip Planning Lists** card (purple, airplane icon)

Each card uses `NavigationLink` to navigate to its respective section.

#### **HomeCardView** (ContentView.swift)
Reusable card component for the home screen with:
- Large icon (SF Symbol)
- Title text
- Colored background with subtle border
- Tap to navigate

#### **PackingListView** (ContentView.swift)
General packing list interface with categories, search, and item management.

**Features:**
- Groups items by `PackingCategory` (clothing, toiletries, electronics, etc.)
- Searchable list
- Packing progress counter ("\(packed) of \(total) packed")
- "Unpack All" button to reset all items
- Add new items via sheet

#### **TripListView** (TripListView.swift)
Main screen showing all trips.

**Features:**
- SwiftData `@Query` sorted by departure date
- Empty state with `ContentUnavailableView`
- Swipe-to-delete trips
- Sheet to add new trip
- Shows trip row with destination, date, packing progress

**Components:**
- `TripRow` — Displays trip name, destination, days until departure, packing progress
- `PackingProgressView` — Progress bar showing packed/total items

---

#### **TripDetailView** (TripDetailView.swift)
Detail screen for a single trip showing all packing items.

**Features:**
- `@Bindable var trip: Trip` for two-way data binding
- Items grouped by category
- Searchable with `.searchable()` modifier
- Empty state when no items
- Swipe-to-delete items
- "Unpack All" button in bottom toolbar
- Sheet to add new item
- Automatically schedules notifications on appear (`.task`)

**Note:** TripDetailView has its own inline implementations of item management views.

---

#### **AddTripView** (AddTripView.swift)
Sheet for creating a new trip.

**Features:**
- Trip name, destination, departure date
- Toggle for notification reminders
- Packing template picker (empty, beach, business, city break, hiking)
- Creates trip + items from template
- Requests notification authorization if enabled

---

#### **PackingItemRow** (ContentView.swift)
Individual packing item row with interactive checkbox used in PackingListView.

**Features:**
- Checkbox toggle with spring animation
- Green checkmark when packed, gray circle when unpacked
- Strikethrough text when packed
- Button-style interaction

**Note:** Similar component exists inline in TripDetailView for trip-specific items.

---

#### **AddItemView** (ContentView.swift)
Form for adding new packing items to the general packing list.
Sheet for adding items to a trip.

**Properties:**
- `let trip: Trip` — The trip to add the item to
- `@State private var name: String`
- `@State private var category: PackingCategory`

**Features:**
- Text field for item name
- Picker for category
- Cancel/Add buttons
- Validation (name cannot be empty)

---

## Notification System

**TripNotificationManager** (TripNotificationManager.swift)

Singleton actor-isolated class managing departure reminders.

### Features
- Requests user authorization
- Schedules two notifications per trip:
  1. **1 day before** at 20:00 — "✈️ [Trip] is tomorrow!"
  2. **Morning of departure** at 07:00 — "🧳 Time to go — [Trip]!"
- Uses trip's `persistentModelID.hashValue` for unique identifiers
- Notifications include packing progress

### Methods
- `requestAuthorization() async -> Bool`
- `scheduleReminders(for trip: Trip) async`
- `cancelReminders(for trip: Trip) async`

---

## File Organization

### Data Models
- **Item.swift** — `Trip`, `PackingItem`, `PackingCategory`, `PackingTemplate` (main models)

### Views
- **ContentView.swift** — Root view (simple packing list interface)
- **TripListView.swift** — List of all trips
- **TripDetailView.swift** — Detail view for a trip + AddItemView
- **AddTripView.swift** — Sheet for creating trips

### Services
- **TripNotificationManager.swift** — Notification scheduling

### App
- **packing_listApp.swift** — App entry point with SwiftData container

### Tests
- **packing_listTests.swift** — Unit test file (empty template)
- **packing_listUITests.swift** — UI test file
- **packing_listUITestsLaunchTests.swift** — Launch test file

---

## Known Issues

### Code Organization Problems

1. **Clean File Structure**
   - Model files consolidated into `Item.swift`
   - View files use standard naming without version numbers

2. **Code Organization**
   - `PackingItemRow` is defined in `ContentView.swift`
   - `AddItemView` is defined in `ContentView.swift`
   - All components properly separated and non-duplicated

3. **Import Statements**
   - All files properly import `SwiftData` where needed
   - No missing dependency issues

### Best Practices Maintained

**Clean file structure:**
- `Item.swift` contains all data models (Trip, PackingItem, PackingCategory, PackingTemplate)
- `ContentView.swift` provides the main packing list interface with supporting views
- `TripListView.swift`, `TripDetailView.swift`, `AddTripView.swift` handle trip management
- No duplicate code or ambiguous declarations

**Proper imports:**
- All files using SwiftData models import `SwiftData`
- SwiftUI imports where needed

---

## Testing Strategy

### Current State
- Test file exists but only has placeholder test
- No actual tests implemented yet

### Recommended Test Coverage

**Unit Tests:**
- Trip packing progress calculation
- PackingTemplate structure
- Category symbol mapping
- Date calculations (days until departure)

**Integration Tests:**
- Creating trips with templates
- Adding/removing items
- Marking items as packed/unpacked
- SwiftData persistence

**UI Tests:**
- Trip creation flow
- Item addition flow
- Search functionality
- Swipe-to-delete

---

## App Configuration

### SwiftData Schema
Defined in `packing_listApp.swift`:
```swift
Schema([Trip.self, PackingItem.self])
```

### Model Configuration
- Not stored in memory only (persistent storage)
- Default configuration used

---

## User Flows

### Creating a Trip
1. Tap "+" in TripListView
2. Enter trip name (required), destination (optional), date
3. Enable/disable reminders
4. Choose template or start empty
5. Tap "Create"

### Adding Items to a Trip
1. Open trip in TripDetailView
2. Tap "+" button
3. Enter item name and select category
4. Tap "Add"

### Packing Items
1. In TripDetailView, tap the circle icon next to an item
2. Item toggles between packed (green checkmark) and unpacked (gray circle)
3. Progress bar updates automatically

### Managing Trips
- **View all trips:** TripListView shows all trips sorted by departure date
- **Delete trip:** Swipe left in TripListView
- **View trip details:** Tap on trip row
- **Unpack all items:** Tap "Unpack All" in TripDetailView bottom toolbar

---

## Future Enhancements (Ideas)

- [ ] Trip editing (change name, destination, date)
- [ ] Item editing (change name, category)
- [ ] Bulk item operations (mark category as packed)
- [ ] Custom templates (save frequently used item lists)
- [ ] Sharing packing lists
- [ ] Quantity per item (e.g., "3 t-shirts")
- [ ] Photo attachments for items
- [ ] Checklist import/export
- [ ] Trip history and statistics
- [ ] Widget showing upcoming trips
- [ ] iPad/Mac support with multi-column layout

---

## Development Notes

### SwiftUI Best Practices Used
- ✅ `@Query` for automatic SwiftData fetching
- ✅ `@Bindable` for two-way model binding
- ✅ `@Environment(\.modelContext)` for database operations
- ✅ `ContentUnavailableView` for empty states
- ✅ `.searchable()` modifier for search
- ✅ `.task` modifier for async operations
- ✅ Proper use of `withAnimation` for state changes

### Code Style
- Struct-based views (no classes)
- Private helper functions prefixed with `private func`
- Computed properties for derived state
- MARK comments for code organization
- Property wrappers at the top of structs

---

## Important Implementation Details

### Trip-Item Relationship
Items are associated with trips via the `PackingItem.trip` property:
```swift
let item = PackingItem(...)
item.trip = trip
modelContext.insert(item)
```

The relationship is bidirectional:
- `Trip.items` contains all items
- `PackingItem.trip` references the parent trip

### Notification Identifiers
Format: `"{tripID}-{type}"` where:
- `tripID` is `trip.persistentModelID.hashValue`
- `type` is either `"dayBefore"` or `"departure"`

### Date Calculations
- "Days until departure" uses `Calendar.current.dateComponents([.day], ...)` 
- Past trips show as "Past" instead of negative days
- Today's trip shows "Today!" instead of "in 0d"

---

## Common Operations

### Querying All Trips
```swift
@Query(sort: \Trip.departureDate) private var trips: [Trip]
```

### Querying All Items for a Trip
```swift
// Trip.items is a SwiftData relationship, already loaded
let items = trip.items
```

### Deleting a Trip with Items
```swift
modelContext.delete(trip) // Cascade deletes items automatically
```

### Grouping Items by Category
```swift
let grouped = Dictionary(grouping: items, by: \.category)
```

---

## Accessibility Considerations

Current implementation includes:
- SF Symbols for visual icons
- Descriptive labels for actions
- Native SwiftUI controls (automatically accessible)

Could be improved with:
- VoiceOver labels for custom buttons
- Dynamic Type support verification
- Reduce Motion considerations for animations

---

## Questions for Code Review

1. Should we keep multiple Item/ContentView files or consolidate?
2. Is the notification timing (20:00 and 07:00) appropriate for all time zones?
3. Should templates be user-editable or hardcoded?
4. Do we need undo/redo support for item deletion?
5. Should trip dates be stored as DateComponents instead of Date?

---

## Version History

**v1.0 (Current)**
- Initial implementation
- Trip and item management
- Category-based organization
- Packing templates
- Notification reminders
- Search functionality

---

**End of Documentation**

> This file should be updated whenever significant architectural changes are made to the codebase. Use it as a reference for understanding the project structure, data flow, and design decisions.
