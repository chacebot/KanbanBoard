# Kanban Board

A simple, custom kanban board application for iOS built with SwiftUI.

## Features

- **Customizable Columns**: Add, edit, and delete columns to match your workflow
- **Card Management**: Create, edit, and delete cards with titles and descriptions
- **Drag and Drop**: Move cards between columns with intuitive drag and drop
- **Persistent Storage**: All data is automatically saved using UserDefaults
- **Clean UI**: Modern SwiftUI interface with smooth animations

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### Initial Xcode Project Creation

Since the source files are already created, you need to create the Xcode project file:

1. **Open Xcode** and select "File > New > Project"
2. Choose **iOS > App**
3. Configure the project:
   - **Product Name**: `KanbanBoard`
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: Choose "None" (we're using UserDefaults)
4. **Save location**: Choose the `/Users/chace/Developer/KanbanBoard` directory
5. **Important**: When prompted, choose "Don't create" for the Git repository (or create one if you want)
6. **Replace generated files**: The project will create some default files. You can delete `ContentView.swift` if it's different from ours, and make sure all the source files in `KanbanBoard/` are added to the project target.

### Adding Source Files to Xcode Project

1. In Xcode, right-click on the `KanbanBoard` folder in the Project Navigator
2. Select "Add Files to KanbanBoard..."
3. Navigate to the `KanbanBoard/KanbanBoard/` directory
4. Select all the `.swift` files and the `Info.plist`
5. Make sure "Copy items if needed" is **unchecked** (files are already in place)
6. Make sure "Add to targets: KanbanBoard" is **checked**
7. Click "Add"

### Building and Running

1. Select your target device or simulator in Xcode
2. Build and run (⌘R) or press the Play button

The app should launch with a default kanban board containing three columns: "To Do", "In Progress", and "Done".

## Project Structure

```
KanbanBoard/
├── KanbanBoard/
│   ├── KanbanBoardApp.swift      # App entry point
│   ├── Models/
│   │   ├── Board.swift           # Board data model
│   │   ├── Column.swift          # Column data model
│   │   └── Card.swift            # Card data model
│   ├── ViewModels/
│   │   └── BoardManager.swift    # Business logic and state management
│   ├── Views/
│   │   ├── ContentView.swift     # Main content view
│   │   ├── KanbanBoardView.swift # Board container view
│   │   ├── ColumnView.swift      # Individual column view
│   │   ├── CardView.swift        # Individual card view
│   │   ├── AddCardView.swift     # Add card form
│   │   ├── EditCardView.swift    # Edit card form
│   │   ├── AddColumnView.swift   # Add column form
│   │   └── EditColumnView.swift  # Edit column form
│   └── Info.plist                # App configuration
└── README.md
```

## Usage

### Creating a Card
1. Tap the "Add Card" button at the bottom of any column
2. Enter a title (required) and optional description
3. Tap "Add" to create the card

### Editing a Card
1. Tap on any card to open the edit view
2. Modify the title or description
3. Tap "Save" to update

### Moving Cards
1. Long press on a card to start dragging
2. Drag it to another column
3. Release to drop the card in the new column

### Managing Columns
- **Add Column**: Tap the "Add Column" button on the right side of the board
- **Edit Column**: Tap the menu (⋯) icon in the column header, then "Edit"
- **Delete Column**: Tap the menu (⋯) icon in the column header, then "Delete"

## Data Persistence

The app uses UserDefaults to persist board data. All changes are automatically saved when you:
- Add, edit, or delete cards
- Add, edit, or delete columns
- Move cards between columns

## Future Enhancements

Potential features for future versions:
- Card due dates and reminders
- Card labels/tags
- Card attachments
- Multiple boards
- iCloud sync
- Dark mode optimizations
- Card search and filtering

## Development

### Building
```bash
xcodebuild -project KanbanBoard.xcodeproj -scheme KanbanBoard -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Running Tests
```bash
xcodebuild test -project KanbanBoard.xcodeproj -scheme KanbanBoard -destination 'platform=iOS Simulator,name=iPhone 15'
```

## License

Personal project - all rights reserved.
