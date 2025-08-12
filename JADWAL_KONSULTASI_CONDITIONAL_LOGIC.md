# Jadwal Konsultasi - Conditional Menu Logic

## 🎯 Overview

Implemented conditional logic in jadwal konsultasi admin to display different menu options based on schedule status and examination completion status.

## 📋 Menu Logic Rules

### 1. **Pending Status** (Menunggu)
**Shows all options:**
- ✅ Lihat Detail
- ✅ Edit
- ✅ Terima
- ✅ Tolak  
- ✅ Hapus

### 2. **Confirmed Status - No Examination** (Diterima - Belum Pemeriksaan)
**Shows limited options:**
- ✅ Lihat Detail
- ✅ Edit
- ✅ Pemeriksaan
- ✅ Hapus

### 3. **Confirmed Status - Examination Completed** (Diterima - Sudah Pemeriksaan)
**Shows minimal options:**
- ✅ Lihat Detail
- ✅ Hapus
- ❌ Edit (removed)
- ❌ Pemeriksaan (removed)

### 4. **Rejected Status** (Ditolak)
**Shows minimal options:**
- ✅ Lihat Detail
- ✅ Hapus
- ❌ Edit (removed)
- ❌ Pemeriksaan (removed)
- ❌ Terima/Tolak (removed)

## 🔧 Technical Implementation

### Database Schema Changes
Added new fields to jadwal konsultasi documents:
```dart
{
  'hasExamination': bool, // true if examination completed
  'examinationDate': String, // ISO date when examination was completed
}
```

### Helper Method
```dart
List<PopupMenuEntry<String>> _buildPopupMenuItems(Map<String, dynamic> schedule) {
  final status = schedule['status'] as String?;
  final hasExamination = schedule['hasExamination'] == true;
  
  // Dynamic menu building based on status and examination state
}
```

### Examination Completion Flow
1. Admin clicks "Lakukan Pemeriksaan"
2. Navigates to PemeriksaanIbuHamilScreen
3. After examination completed, returns `true`
4. Calls `_markExaminationCompleted()` to update schedule
5. UI automatically updates with new menu options

## 🎨 UI Changes

### Visual Indicators

#### Before Examination (Confirmed)
- **Button**: "Lakukan Pemeriksaan" (pink button)
- **Menu**: Edit, Pemeriksaan, Delete options available

#### After Examination (Completed)
- **Indicator**: Green success message "Pemeriksaan telah dilakukan"
- **Menu**: Only Detail and Delete options available

#### Rejected Status
- **Indicator**: Red status badge "Ditolak"
- **Menu**: Only Detail and Delete options available

### Code Structure
```dart
// Conditional button display
if (isConfirmed && schedule['hasExamination'] != true)
  // Show "Lakukan Pemeriksaan" button

if (isConfirmed && schedule['hasExamination'] == true)
  // Show "Pemeriksaan telah dilakukan" indicator
```

## 🚀 Benefits

### For Admin Users
1. **Clear Status Tracking**: Easy to see which appointments need examination
2. **Prevent Duplicate Examinations**: Can't perform examination twice
3. **Simplified Workflow**: Relevant options only
4. **Visual Feedback**: Clear indicators for completed examinations

### For Data Integrity
1. **Status Consistency**: Examination state tracked in database
2. **Audit Trail**: Examination completion timestamp recorded
3. **Prevent Errors**: Invalid actions blocked by UI

### For User Experience
1. **Intuitive Interface**: Only show relevant actions
2. **Reduced Confusion**: No unnecessary options
3. **Clear Progress**: Visual progression from pending → confirmed → examined

## 📱 User Flow Examples

### Example 1: New Appointment
1. **Status**: Pending
2. **Available Actions**: Detail, Edit, Terima, Tolak, Hapus
3. **Admin Action**: Clicks "Terima"
4. **New Status**: Confirmed (no examination)
5. **Available Actions**: Detail, Edit, Pemeriksaan, Hapus

### Example 2: Performing Examination
1. **Status**: Confirmed (no examination)
2. **Admin Action**: Clicks "Lakukan Pemeriksaan"
3. **Navigation**: Goes to PemeriksaanIbuHamilScreen
4. **Completion**: Saves examination data
5. **Return**: Schedule marked as examined
6. **New Available Actions**: Detail, Hapus only

### Example 3: Rejected Appointment
1. **Status**: Pending
2. **Admin Action**: Clicks "Tolak"
3. **New Status**: Rejected
4. **Available Actions**: Detail, Hapus only
5. **UI**: Red status indicator, no examination options

## 🔍 Code Changes Made

### Files Modified
1. **`lib/admin/jadwal_konsultasi.dart`**
   - Added `_buildPopupMenuItems()` helper method
   - Updated PopupMenuButton in both sections
   - Added `_markExaminationCompleted()` method
   - Enhanced `_navigateToPemeriksaan()` with completion handling
   - Added conditional UI for examination status

### New Methods
```dart
// Build dynamic menu items based on status
List<PopupMenuEntry<String>> _buildPopupMenuItems(Map<String, dynamic> schedule)

// Mark examination as completed
Future<void> _markExaminationCompleted(String scheduleId)
```

### Enhanced Methods
```dart
// Updated to handle examination completion result
void _navigateToPemeriksaan(Map<String, dynamic> schedule)
```

## 🧪 Testing Checklist

### Functional Testing
- [ ] Pending appointments show all menu options
- [ ] Confirmed appointments show examination option
- [ ] Completed examinations hide examination option
- [ ] Rejected appointments show minimal options
- [ ] Examination completion updates schedule correctly
- [ ] UI reflects status changes immediately

### UI Testing
- [ ] Menu items display correctly for each status
- [ ] Status indicators show appropriate colors
- [ ] Examination completion message appears
- [ ] Buttons enable/disable appropriately
- [ ] Visual consistency across all states

### Error Testing
- [ ] Network errors handled gracefully
- [ ] Invalid status values don't crash app
- [ ] Examination marking failures show error message
- [ ] Schedule updates work properly

## 🔮 Future Enhancements

### Potential Additions
1. **Examination History**: Track multiple examinations
2. **Examination Notes**: Add quick notes to examination completion
3. **Bulk Status Updates**: Update multiple schedules at once
4. **Status Change Notifications**: Notify patients of status changes
5. **Examination Reports**: Generate examination summaries

### Advanced Features
1. **Role-based Permissions**: Different menu options for different admin roles
2. **Schedule Templates**: Pre-defined examination procedures
3. **Integration**: Connect with external medical systems
4. **Analytics**: Track examination completion rates

## 📊 Status Summary

### Implementation Status
- ✅ Conditional menu logic implemented
- ✅ Database schema enhanced
- ✅ UI indicators added
- ✅ Examination completion tracking
- ✅ Error handling implemented
- ✅ User feedback mechanisms

### Testing Status
- ⏳ Functional testing needed
- ⏳ UI testing needed  
- ⏳ Integration testing needed
- ⏳ User acceptance testing needed

This implementation provides a clear, logical flow for managing consultation schedules with proper state management and user-friendly interfaces.
