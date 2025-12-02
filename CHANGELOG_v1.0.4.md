# Changelog - Version 1.0.4

## Release Date
December 2, 2024

## Bug Fixes

### 🐛 Practice Time Calculation
- **Fixed**: Practice time on Home screen now correctly shows only completed sessions
- **Fixed**: Weekly practice time on Progress screen now filters completed sessions only
- Previously was counting all sessions including incomplete/active ones

### 🐛 Task Completion Count
- **Fixed**: Task completion count on Home screen now accurately reflects today's tasks
- Improved logic to include:
  - Tasks scheduled for today (both completed and incomplete)
  - Tasks completed today regardless of schedule
  - Daily recurring tasks
  - Weekly tasks that are due
- Fixed issue where completion count was showing incorrect numbers

## New Features

### 🎨 System Theme Support
- **Added**: System theme mode option (Light / Dark / System Default)
- Theme now defaults to system settings on first launch
- Users can override with their preference:
  - **Light**: Always use light theme
  - **Dark**: Always use dark theme
  - **System Default**: Follow system settings (NEW)

### 📦 Data Export
- **Added**: Export all your data as JSON
- **Location**: Settings → Data → Export Data
- Exports include:
  - All skills with levels and descriptions
  - All tasks with completion status
  - All practice sessions with durations and notes
  - All purposes/motivations
- Exported file can be shared via any app
- Filename format: `prompt_loop_export_YYYYMMDD_HHMMSS.json`
- Supports data ownership and backup

## Technical Details

### Version
- Version: 1.0.4+6
- Build: 6

### File Size
- Release APK: 53.4MB

### Changes Summary
- Modified `todaysPracticeTimeProvider` to filter completed sessions
- Modified `weeklyPracticeTimeProvider` to filter completed sessions
- Updated `todaysTasksProvider` logic for accurate task filtering
- Added `AppThemeMode` enum with system support
- Updated theme system in `app.dart` and `settings_provider.dart`
- Added export functionality in `SettingsScreen`
- Updated dependencies for share functionality

## Testing Recommendations

1. **Theme Testing**:
   - Change device theme → verify app follows system
   - Change app theme to Light → verify stays light regardless of system
   - Change app theme to Dark → verify stays dark regardless of system
   - Change app theme to System → verify follows device settings

2. **Practice Time Testing**:
   - Start a practice session
   - Check Home screen → should NOT count incomplete session
   - Complete the session
   - Check Home screen → should now count in practice time
   - Check Progress screen → should show in weekly total

3. **Task Count Testing**:
   - Add tasks for today
   - Check Home screen → should show X/Y format
   - Complete a task
   - Check Home screen → count should update correctly
   - Verify completed tasks still appear in today's list

4. **Export Testing**:
   - Go to Settings → Data → Export Data
   - Wait for export dialog
   - Verify share sheet appears
   - Save/share the JSON file
   - Verify JSON contains all data sections

## Known Issues
None

## Next Steps
- Consider adding import functionality
- Consider adding more export formats (CSV, PDF)
- Consider cloud backup integration
