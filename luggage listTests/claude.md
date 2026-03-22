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

### `PackingList` (Item.swift)
A reusable packing list containing items organized by category.

**Properties:**
- `name: String` — List name (e.g., "Weekend Trip Essentials", "Winter Vacation")
- `createdDate: Date` — When the list was created
- `items: [PackingItem]` — Items in this list with cascade delete relationship

**Computed Properties:**
- `packedCount: Int` — Number of items marked as packed
- `progress: Double` — Packing completion (0.0 to 1.0)

**Relationships:**
- One-to-many with `PackingItem` (inverse: `\PackingItem.packingList`)
- Delete rule: `.cascade` (deleting a list deletes all its items)

---

### `Trip` (Item.swift)
A planned trip with destination, date, and trip-specific packing items.

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
Individual items that can belong to either a packing list or a trip.

**Properties:**
- `name: String` — Item name (e.g., "Passport", "Sunglasses")
- `category: PackingCategory` — Item category (enum)
- `isPacked: Bool` — Whether the item is packed (default: false)
- `trip: Trip?` — Optional reference to parent trip
- `packingList: PackingList?` — Optional reference to parent packing list

**Note:** An item belongs to either a trip OR a packing list, not both.

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

### No Legacy Models

All models are actively used in the app. The original Xcode template model has been removed.

---

## Packing Templates

Pre-defined item lists for common trip types (Item.swift):

- **🏖️ Beach** — Swimsuit, sunscreen, flip flops, etc.
- **💼 Business** — Suit, laptop, business cards, etc.
- **🏙️ City Break** — Jeans, t-shirts, comfortable shoes, etc.
- **🥾 Hiking** — Hiking boots, rain jacket, first aid kit, etc.

Templates are used when creating a new trip to quickly populate trip items.

---

## Views & Navigation

### Navigation Hierarchy

```
ContentView (ContentView.swift) — "Packing & Travel" Home Screen
  │
  ├─ HomeCardView (blue) → NavigationLink to PackingListView
  │    └─ PackingListView (PackingListView.swift)
  │         ├─ List of PackingList objects
  │         ├─ Floating + button (bottom center, blue circle)
  │         └─ PackingListDetailView (PackingListView.swift) [NavigationLink]
  │              ├─ Grouped by PackingCategory
  │              ├─ PackingListItemRow (inline component)
  │              └─ AddItemToPackingListView (sheet for adding items)
  │
  └─ HomeCardView (purple) → NavigationLink to TripListView
       └─ TripListView (TripListView.swift)
            ├─ TripDetailView (TripDetailView.swift) [NavigationLink]
            │    ├─ TripItemRow (inline)
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

#### **PackingListView** (PackingListView.swift)
Shows list of all packing lists with floating add button.

**Features:**
- SwiftData `@Query` sorted by creation date (newest first)
- Empty state: "No lists created yet, tap + to create a new list!"
- List showing all packing lists with progress bars
- **Floating + button** (blue circle, bottom center, white plus icon, shadow)
- Swipe-to-delete packing lists
- Sheet to create new packing list

**Components:**
- `PackingListRow` — Displays list name, item count, progress bar
- `AddPackingListView` — Sheet for creating new packing list

---

#### **PackingListDetailView** (PackingListView.swift)
Detail screen for a single packing list showing all items.

**Features:**
- `@Bindable var packingList: PackingList` for two-way data binding
- Items grouped by category
- Searchable with `.searchable()` modifier
- Empty state when no items
- Swipe-to-delete items
- "Unpack All" button in bottom toolbar
- Sheet to add new item
- Top navigation bar + button to add items

**Components:**
- `PackingListItemRow` — Checkbox-style row with toggle animation
- `AddItemToPackingListView` — Form to add new item to packing list

---

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

**Components:**
- `TripItemRow` — Checkbox-style row with toggle animation for trip items
- `AddTripItemView` — Form to add new item to trip

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

---

## Notification System

**TripNotificationManager** (TripNotificationManager.swift)

Singleton actor-isolated class managing departure reminders for trips only (not packing lists).

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
- **Item.swift** — `PackingList`, `Trip`, `PackingItem`, `PackingCategory`, `PackingTemplate`

### Views

**Home Screen:**
- **ContentView.swift** — Home screen with two navigation cards

**Packing Lists:**
- **PackingListView.swift** — All packing list views:
  - `PackingListView` — List of all packing lists
  - `PackingListRow` — Row for each packing list
  - `AddPackingListView` — Sheet for creating new packing list
  - `PackingListDetailView` — Detail view for a packing list
  - `PackingListItemRow` — Row for items in a packing list
  - `AddItemToPackingListView` — Sheet for adding items to packing list

**Trips:**
- **TripListView.swift** — List of all trips, `TripRow`, `PackingProgressView`
- **TripDetailView.swift** — Detail view for a trip, `TripItemRow`, `AddTripItemView`
- **AddTripView.swift** — Sheet for creating trips with templates

### Services
- **TripNotificationManager.swift** — Notification scheduling for trips

### App
- **packing_listApp.swift** — App entry point with SwiftData container

### Tests
- **packing_listTests.swift** — Unit test file (empty template)
- **packing_listUITests.swift** — UI test file
- **packing_listUITestsLaunchTests.swift** — Launch test file

---

## Code Organization

### File Structure

✅ **Clean and Organized**
- Model files consolidated into `Item.swift`
- View files separated by feature (home, packing lists, trips)
- No duplicate code or version numbers in filenames
- Clear naming conventions (TripItemRow vs PackingListItemRow)

### Component Organization

**Home Screen (ContentView.swift):**
- `ContentView` — Main home screen
- `HomeCardView` — Reusable navigation card component

**Packing Lists (PackingListView.swift):**
- All packing list related views in one file
- Clear separation from trip functionality

**Trips (TripListView.swift, TripDetailView.swift, AddTripView.swift):**
- Trip views separated across multiple files
- Each file has focused responsibility

### Best Practices Maintained

**Clean file structure:**
- `Item.swift` contains all data models (PackingList, Trip, PackingItem, PackingCategory, PackingTemplate)
- `ContentView.swift` provides the home screen only
- `PackingListView.swift` handles all packing list functionality
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
- Creating packing lists and trips
- Creating packing lists with templates
- Adding/removing items to packing lists and trips
- Marking items as packed/unpacked
- SwiftData persistence for both models

**UI Tests:**
- Packing list creation flow
- Trip creation flow
- Item addition flow (both packing lists and trips)
- Search functionality
- Swipe-to-delete
- Floating button interaction

---

## App Configuration

### SwiftData Schema
Defined in `packing_listApp.swift`:
```swift
Schema([
    Trip.self, 
    PackingItem.self,
    PackingList.self
])
```

### Model Configuration
- Not stored in memory only (persistent storage)
- Default configuration used

---

## User Flows

### Creating a Packing List
1. From home screen, tap "Packing Lists" card
2. Tap floating blue + button at bottom center
3. Enter list name
4. Tap "Create"
5. New list appears in the list

### Adding Items to a Packing List
1. Tap on a packing list
2. Tap "+" button in navigation bar
3. Enter item name and select category
4. Tap "Add"

### Creating a Trip
1. From home screen, tap "Trip Planning Lists" card
2. Tap "+" in navigation bar
3. Enter trip name (required), destination (optional), date
4. Enable/disable reminders
5. Choose template or start empty
6. Tap "Create"

### Adding Items to a Trip
1. Open trip in TripDetailView
2. Tap "+" button
3. Enter item name and select category
4. Tap "Add"

### Managing Packing Lists
- **View all lists:** PackingListView shows all lists sorted by creation date (newest first)
- **Delete list:** Swipe left on a list
- **View list details:** Tap on list row
- **Unpack all items:** Tap "Unpack All" in PackingListDetailView bottom toolbar

### Managing Trips
- **View all trips:** TripListView shows all trips sorted by departure date
- **Delete trip:** Swipe left in TripListView
- **View trip details:** Tap on trip row
- **Unpack all items:** Tap "Unpack All" in TripDetailView bottom toolbar

---

## Future Enhancements (Ideas)

- [ ] Packing list editing (rename lists)
- [ ] Trip editing (change name, destination, date)
- [ ] Item editing (change name, category)
- [ ] Bulk item operations (mark category as packed)
- [ ] Custom templates (save frequently used item lists)
- [ ] Share packing lists with others
- [ ] Copy items from packing list to trip
- [ ] Quantity per item (e.g., "3 t-shirts")
- [ ] Photo attachments for items
- [ ] Checklist import/export
- [ ] Trip history and statistics
- [ ] Widget showing upcoming trips and packing progress
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
