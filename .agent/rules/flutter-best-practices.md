---
trigger: always_on
---

# Flutter Best Practices & Modern Patterns

## **Core Principle**
**NEVER use deprecated APIs, methods, or patterns in Flutter/Dart code.** Always use the latest recommended approaches and modern Flutter patterns.

## **Deprecated APIs to Avoid**

### **Text Styles (Prefer new naming)**
```dart
// ❌ DON'T: Use deprecated text style names
Text('Hello', style: Theme.of(context).textTheme.headline6)
Text('Hello', style: Theme.of(context).textTheme.bodyText1)

// ✅ DO: Use modern text style names
Text('Hello', style: Theme.of(context).textTheme.titleLarge)
Text('Hello', style: Theme.of(context).textTheme.bodyLarge)
```

### **Navigation (Prefer GoRouter)**
```dart
// ❌ DON'T: Use deprecated Navigator.push
Navigator.push(context, MaterialPageRoute(builder: (context) => Screen()));

// ✅ DO: Use GoRouter or modern navigation
context.go('/screen');
context.push('/screen');
```

### **State Management (Prefer Riverpod)**
```dart
// ❌ DON'T: Use deprecated StateNotifierProvider
StateNotifierProvider<CounterNotifier, int>

// ❌ DON'T: Use deprecated parent parameter
ProviderScope(parent: container, child: MyWidget())

// ✅ DO: Use modern Riverpod patterns
@riverpod
class CounterNotifier extends _$CounterNotifier {
  @override
  int build() => 0;
}

// ✅ DO: Use overrides instead of parent
ProviderScope(overrides: [], child: MyWidget())
```

### **Provider Invalidation Chain Principle**
```dart
// ❌ DON'T: Only invalidate dependent providers
ref.invalidate(habitProvider(habitId)); // Doesn't refresh data source

// ✅ DO: Invalidate root data source provider for complete refresh
ref.invalidate(habitViewModelProvider); // Refreshes all dependent providers
ref.invalidate(habitProvider(habitId)); // Also invalidate specific provider
```

### **Provider Error Handling**
```dart
// ❌ DON'T: Throw exceptions in providers
final habitProvider = Provider.family<AsyncValue<Habit>, String>((ref, habitId) {
  final habit = habitList.firstWhere(
    (h) => h.id == habitId,
    orElse: () => throw Exception('Habit not found'), // Unhandled exception
  );
  return AsyncValue.data(habit);
});

// ✅ DO: Return proper error states
final habitProvider = Provider.family<AsyncValue<Habit>, String>((ref, habitId) {
  try {
    final habit = habitList.firstWhere((h) => h.id == habitId);
    return AsyncValue.data(habit);
  } catch (e) {
    return AsyncValue.error('Habit with ID $habitId not found', StackTrace.current);
  }
});
```

### **Provider Architecture for Computed State**
```dart
// ✅ DO: Create computed providers for derived state
final availableFiltersProvider = Provider<AvailableFilters>((ref) {
  final habitsAsync = ref.watch(habitViewModelProvider);
  
  return habitsAsync.when(
    data: (habits) {
      final habitList = habits as List<Habit>;
      final today = DateTime.now();
      
      // Compute derived state from base data
      final availableCategories = habitList
          .map((habit) => habit.category)
          .toSet()
          .toList();
      
      final hasCompletedToday = habitList.any((habit) => 
          habit.isCompletedForDate(today));
      
      return AvailableFilters(
        availableCategories: availableCategories,
        hasCompletedToday: hasCompletedToday,
      );
    },
    loading: () => const AvailableFilters(
      availableCategories: [],
      hasCompletedToday: false,
    ),
    error: (_, __) => const AvailableFilters(
      availableCategories: [],
      hasCompletedToday: false,
    ),
  );
});

// ❌ DON'T: Embed computed logic directly in UI components
class _FilterSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitViewModelProvider);
    
    // ❌ DON'T: Compute derived state in UI
    final availableCategories = habitsAsync.when(
      data: (habits) => habits.map((h) => h.category).toSet().toList(),
      // ... complex logic in UI component
    );
    
    return Row(children: [
      // UI rendering mixed with business logic
    ]);
  }
}
```

### **Widget Constructors**
```dart
// ❌ DON'T: Use deprecated constructors
RaisedButton(onPressed: () {}, child: Text('Button'))
FlatButton(onPressed: () {}, child: Text('Button'))

// ✅ DO: Use modern button widgets
ElevatedButton(onPressed: () {}, child: Text('Button'))
TextButton(onPressed: () {}, child: Text('Button'))
```


## **Modern Flutter Patterns**

### **Use const constructors**
```dart
// ✅ DO: Use const for immutable widgets
const Text('Hello')
const SizedBox(height: 16)
const Icon(Icons.star)
```

### **Prefer composition over inheritance**
```dart
// ✅ DO: Use composition
class MyWidget extends StatelessWidget {
  final Widget child;
  const MyWidget({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
```

### **Use modern async patterns**
```dart
// ✅ DO: Use modern async/await patterns
Future<void> loadData() async {
  try {
    final data = await repository.getData();
    state = AsyncValue.data(data);
  } catch (error, stack) {
    state = AsyncValue.error(error, stack);
  }
}
```

## **Code Generation Best Practices**

### **Use build_runner properly**
```bash
# ✅ DO: Use proper build_runner commands
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch
```

### **Freezed for immutable data**
```dart
// ✅ DO: Use Freezed for data classes
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
  }) = _User;
}
```

## **Performance Best Practices**

### **Use const widgets**
```dart
// ✅ DO: Use const for static widgets
const ListView(
  children: [
    Text('Item 1'),
    Text('Item 2'),
    Text('Item 3'),
  ],
)
```

### **Prefer ListView.builder for large lists**
```dart
// ✅ DO: Use ListView.builder for performance
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(
    title: Text(items[index].title),
  ),
)
```

## **Error Handling**

### **Use AsyncValue for proper error states**
```dart
// ✅ DO: Use AsyncValue for comprehensive error handling
AsyncValue<List<Item>> itemsAsync = ref.watch(itemsProvider);

return itemsAsync.when(
  data: (items) => ListView.builder(...),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error.toString()),
);
```

## **Data Integrity & State Preservation**

### **Preserve entity state during edit operations**
```dart
// ✅ DO: Preserve existing entity state when creating updated entities
Habit _createHabitFromForm() {
  // For edit mode, preserve original data
  int? currentStreak;
  int? longestStreak;
  List<DateTime>? completedDates;
  
  if (_isEditMode && widget.habitId != null) {
    final existingHabit = _getExistingHabit();
    currentStreak = existingHabit.currentStreak;
    longestStreak = existingHabit.longestStreak;
    completedDates = existingHabit.completedDates;
  }
  
  return Habit(
    // ... other fields
    currentStreak: currentStreak ?? 0,
    longestStreak: longestStreak ?? 0,
    completedDates: completedDates ?? [],
  );
}

// ❌ DON'T: Overwrite existing state with defaults
Habit _createHabitFromForm() {
  return Habit(
    // ... other fields
    currentStreak: 0, // This resets existing streaks!
    longestStreak: 0, // This resets existing streaks!
    completedDates: [], // This loses completion history!
  );
}
```

## **Testing Best Practices**

### **Use modern testing patterns**
```dart
// ✅ DO: Use modern testing approaches
testWidgets('should display items', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemsProvider.overrideWith((ref) => [Item(id: '1', name: 'Test')]),
      ],
      child: const MyWidget(),
    ),
  );
  
  expect(find.text('Test'), findsOneWidget);
});
```

### **Test Import Paths**
```dart
// ❌ DON'T: Use relative imports in test files
import '../../../lib/domain/entities/habit.dart';
import '../../../lib/core/services/data_service.dart';

// ✅ DO: Use package imports in test files
import 'package:habbitator/domain/entities/habit.dart';
import 'package:habbitator/core/services/data_service.dart';
```

### **Test Binding Initialization**
```dart
// ✅ DO: Initialize Flutter binding for tests requiring services
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Service Tests', () {
    test('should handle file operations', () async {
      // Tests that require Flutter services
    });
  });
}
```

## **Data-Driven UI Patterns**

### **Conditional Rendering Based on Data**
```dart
// ✅ DO: Use data-driven conditional rendering
class _FilterSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableFilters = ref.watch(availableFiltersProvider);
    
    return Row(
      children: [
        // Always show core filters
        _FilterChip(label: 'All', ...),
        _FilterChip(label: 'Active', ...),
        
        // Show conditional filters based on data
        if (availableFilters.hasCompletedToday) ...[
          const SizedBox(width: 8),
          _FilterChip(label: 'Completed', ...),
        ],
        
        // Show dynamic category filters
        ...availableFilters.availableCategories.map((category) => [
          const SizedBox(width: 8),
          _FilterChip(label: category.name, ...),
        ]).expand((element) => element),
      ],
    );
  }
}

// ❌ DON'T: Hardcode all possible filters regardless of data
class _FilterSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _FilterChip(label: 'All', ...),
        _FilterChip(label: 'Active', ...),
        _FilterChip(label: 'Completed', ...), // Always shown
        _FilterChip(label: 'Health', ...),     // Always shown
        _FilterChip(label: 'Fitness', ...),    // Always shown
        // ... all categories always visible
      ],
    );
  }
}
```

## **Import Management & Dependency Resolution**

### **Import Resolution Protocol**
```dart
// ✅ DO: Always verify import statements are correctly added
import '../../core/services/premium_service.dart'; // Verify path is correct

// ✅ DO: Remove unused imports immediately
// ❌ DON'T: Leave unused imports that cause analyzer warnings

// ✅ DO: Use flutter clean when encountering phantom analyzer issues
// flutter clean && flutter pub get
```

### **Dependency Research Protocol**
```dart
// ✅ DO: Research known issues with new dependencies before integration
// - Check pub.dev for known issues
// - Research platform-specific build problems (iOS/Android)
// - Verify compatibility with current Flutter version

// ❌ DON'T: Add dependencies without researching potential conflicts
// Example: RevenueCat has known iOS Swift compilation issues
```

### **Native Plugin Integration Validation Protocol**

**Platform Requirements Verification:**
- **iOS Deployment Target:** Check minimum iOS version requirements (e.g., iOS 13.0+ for purchases_flutter)
- **Android minSdk:** Verify minimum Android SDK version compatibility
- **Configuration Updates:** Update platform-specific files (Podfile, build.gradle)
- **End-to-End Testing:** Test build on target platforms after integration

**RevenueCat Integration Example:**
- Update `ios/Podfile`: `platform :ios, '13.0'`
- Update `ios/Runner.xcodeproj`: `IPHONEOS_DEPLOYMENT_TARGET = 13.0`
- Run: `cd ios && pod install`
- Test: `flutter build ios --no-codesign`

**Common Mistakes:**
- ❌ Adding native plugins without verifying platform compatibility
- ❌ Marking tasks complete without end-to-end functionality verification

### **Cache Clearing Protocol**
```bash
# ✅ DO: Use clean/rebuild commands when en