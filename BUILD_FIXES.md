# Build Fix Checklist

If you're experiencing build errors, check the following:

## 1. Add ImageStorage.swift to Xcode Project

**CRITICAL**: The `ImageStorage.swift` file must be added to your Xcode project target.

1. In Xcode Project Navigator, right-click on `KanbanBoard` folder
2. Select "Add Files to KanbanBoard..."
3. Navigate to: `KanbanBoard/KanbanBoard/Utilities/ImageStorage.swift`
4. **IMPORTANT**: Check "Add to targets: KanbanBoard"
5. Click "Add"

## 2. Verify iOS Deployment Target

1. Select the project in Xcode
2. Select the "KanbanBoard" target
3. Go to "General" tab
4. Set "iOS Deployment Target" to **17.0** or higher

## 3. Verify All Files Are in Target

Check that these files are included in the build:
- ✅ Models/Card.swift
- ✅ Models/Column.swift  
- ✅ Models/Board.swift
- ✅ ViewModels/BoardManager.swift
- ✅ Views/ContentView.swift
- ✅ Views/KanbanBoardView.swift
- ✅ Views/ColumnView.swift
- ✅ Views/CardView.swift
- ✅ Views/AddCardView.swift
- ✅ Views/EditCardView.swift
- ✅ Utilities/ImageStorage.swift ← **Most likely missing!**

To check: Select each file in Project Navigator, open File Inspector (right panel), verify "Target Membership" shows "KanbanBoard" is checked.

## 4. Common Build Errors and Fixes

### Error: "Cannot find 'ImageStorage' in scope"
**Fix**: Add `ImageStorage.swift` to project (see #1 above)

### Error: "'PhotosPicker' is unavailable"
**Fix**: Set iOS Deployment Target to 17.0+ (see #2 above)

### Error: "Value of type 'PhotosPickerItem' has no member 'loadTransferable'"
**Fix**: Ensure iOS 17.0+ deployment target and import PhotosUI

### Error: "Type 'Card' does not conform to protocol 'Equatable'"
**Fix**: This shouldn't happen, but if it does, the Card struct should auto-conform. Try cleaning build folder (Cmd+Shift+K) and rebuilding.

## 5. Clean Build

If errors persist:
1. Product → Clean Build Folder (Cmd+Shift+K)
2. Close Xcode
3. Delete `DerivedData` folder (optional)
4. Reopen Xcode and rebuild
