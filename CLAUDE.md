# Claude Rules for Kanban Board

This file provides guidance to Claude Code when working with code in this repository.

## Build & Run Commands

This is an iOS SwiftUI application:

```bash
# Open project in Xcode
open KanbanBoard.xcodeproj

# Build from command line
xcodebuild -project KanbanBoard.xcodeproj -scheme KanbanBoard -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild test -project KanbanBoard.xcodeproj -scheme KanbanBoard -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

### Tech Stack
- **SwiftUI** for UI
- **Swift 5.9+**
- **iOS 17.0+**
- **UserDefaults** for persistence

### Project Structure
- `KanbanBoard/Models/` - Data models (Board, Column, Card)
- `KanbanBoard/ViewModels/` - Business logic and state management (BoardManager)
- `KanbanBoard/Views/` - SwiftUI views
- `KanbanBoard/KanbanBoardApp.swift` - App entry point

### Patterns
- MVVM architecture pattern
- ObservableObject for state management
- Codable for data persistence
- SwiftUI declarative UI

## Code Review Focus Areas

When reviewing code in this project, pay special attention to:

### SwiftUI Best Practices
- Proper use of @State, @StateObject, and @EnvironmentObject
- View composition and reusability
- Performance considerations (avoid unnecessary view updates)
- Accessibility support

### Data Management
- Proper state management in BoardManager
- Data persistence correctness
- Thread safety (SwiftUI is main-thread only)

### Code Quality
- Swift naming conventions
- Type safety and proper use of Optionals
- Error handling
- Code organization and separation of concerns

### UI/UX
- Responsive design for different screen sizes
- Smooth animations and transitions
- Intuitive drag and drop interactions
- Clear visual hierarchy

## Review Checklist

When reviewing code changes:
- [ ] Code compiles without errors or warnings
- [ ] Follows Swift and SwiftUI best practices
- [ ] Proper state management patterns
- [ ] Views are composable and reusable
- [ ] Data persistence works correctly
- [ ] UI is responsive and accessible
- [ ] No memory leaks or retain cycles
- [ ] Proper error handling
- [ ] Documentation updated if needed
