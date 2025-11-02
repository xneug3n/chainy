# Chainy - Task Übersicht

Diese Datei enthält eine menschenlesbare Übersicht aller Tasks und Subtasks aus der tasks.json.

**Letzte Aktualisierung:** 2025-10-30  
**Kontext:** master

---

## Task 1: Set up Flutter project with iOS-optimized design system

**Status:** ✅ done  
**Priorität:** high  
**Abhängigkeiten:** keine

### Beschreibung
Initialize the Flutter project with the required dependencies and implement the design system with the specified color palette for both light and dark mode.

### Details
1. Create a new Flutter project using the latest stable version
2. Set up project structure following clean architecture principles
3. Implement the ChainyColors class as specified in the PRD
4. Create theme data for both light and dark mode
5. Implement dynamic theme switching based on system settings
6. Set up basic navigation structure with TabBar (Home, Statistics, Achievements, Settings)
7. Implement accessibility support including dynamic type, VoiceOver compatibility, and proper contrast ratios
8. Create reusable UI components that follow the iOS design guidelines

### Test Strategie
1. Verify that the app correctly applies light and dark themes based on system settings
2. Test dynamic type support by changing system font size settings
3. Validate color contrast ratios using accessibility tools
4. Test VoiceOver compatibility for all UI components
5. Verify that the app respects 'Reduce Motion' settings
6. Ensure all touch targets meet the minimum 44pt requirement
7. Test theme consistency across all screens and components

### Subtasks

#### 1.1: Create Flutter project and implement clean architecture structure
- **Status:** ✅ done
- **Abhängigkeiten:** keine
- **Beschreibung:** Initialize a new Flutter project with the latest stable version and set up the project structure following clean architecture principles.

#### 1.2: Implement ChainyColors class and theme system
- **Status:** ✅ done
- **Abhängigkeiten:** 1.1
- **Beschreibung:** Create the ChainyColors class with the specified color palette and implement theme data for both light and dark mode with dynamic switching.

#### 1.3: Create iOS-styled reusable UI components and navigation structure
- **Status:** ✅ done
- **Abhängigkeiten:** 1.2
- **Beschreibung:** Develop a set of reusable UI components following iOS design guidelines and implement the basic TabBar navigation structure.

---

## Task 2: Implement Habit data model and storage

**Status:** ✅ done  
**Priorität:** high  
**Abhängigkeiten:** Task 1

### Beschreibung
Create the data model for habits with all required fields and implement local storage functionality.

### Details
1. Define the Habit data model with fields: id, name, icon/emoji, color, goalType, targetValue, unit, recurrenceType, recurrenceConfig, note, createdAt, updatedAt
2. Implement a RecurrenceConfig class to handle different recurrence patterns
3. Set up local storage using Hive, SQLite, or shared_preferences
4. Implement CRUD operations for habits
5. Create a HabitRepository class to handle data operations

### Test Strategie
1. Unit tests for Habit model serialization/deserialization
2. Unit tests for RecurrenceConfig logic with various recurrence patterns
3. Unit tests for HabitRepository CRUD operations
4. Integration tests for database operations
5. Test edge cases

### Subtasks

#### 2.1: Define Habit and RecurrenceConfig data models
- **Status:** ✅ done
- **Abhängigkeiten:** keine
- **Beschreibung:** Create the Habit class with all required fields and implement the RecurrenceConfig class to handle different recurrence patterns.

#### 2.2: Set up local storage infrastructure
- **Status:** ✅ done
- **Abhängigkeiten:** 2.1
- **Beschreibung:** Evaluate and implement the appropriate local storage solution (Hive, SQLite, or shared_preferences) based on the application's complexity needs.

#### 2.3: Implement HabitRepository for CRUD operations
- **Status:** ✅ done
- **Abhängigkeiten:** 2.1, 2.2
- **Beschreibung:** Create a HabitRepository class that handles all data operations for habits, including create, read, update, and delete functionality.

---

## Task 3: Implement Check-in data model and streak logic

**Status:** ✅ done  
**Priorität:** high  
**Abhängigkeiten:** Task 2

### Beschreibung
Create the data model for habit check-ins and implement the streak calculation logic according to the specified rules.

### Details
1. Define the CheckIn data model with fields: id, habitId, date, value, note, createdAt, updatedAt, isBackfilled
2. Implement streak calculation logic for binary and quantitative habits
3. Create a CheckInRepository class to handle data operations
4. Implement streak calculation service

### Test Strategie
1. Unit tests for CheckIn model serialization/deserialization
2. Unit tests for streak calculation with various scenarios
3. Integration tests for database operations
4. Test edge cases

### Subtasks

#### 3.1: Implement CheckIn data model and serialization
- **Status:** ✅ done
- **Abhängigkeiten:** keine
- **Beschreibung:** Create the CheckIn class with all required fields and implement JSON serialization/deserialization methods.

#### 3.2: Create CheckInRepository for data operations
- **Status:** ✅ done
- **Abhängigkeiten:** 3.1
- **Beschreibung:** Implement a repository class to handle all database operations related to check-ins including CRUD operations.

#### 3.3: Implement streak calculation service
- **Status:** ✅ done
- **Abhängigkeiten:** 3.1, 3.2
- **Beschreibung:** Create a service to calculate and manage streak data based on check-in history and habit requirements.

---

## Task 4: Implement Home screen with habit list and segmented timeline

**Status:** ✅ done  
**Priorität:** high  
**Abhängigkeiten:** Task 1, Task 2, Task 3

### Beschreibung
Create the main Home screen with a vertical list of habits, each with a segmented timeline for tracking progress and interactive elements for check-ins.

### Details
1. Create a HomeScreen widget with a TabBar navigation
2. Implement a vertical ListView for displaying habits
3. Create a HabitRow widget with icon, name, segmented timeline, streak indicator, and week strip
4. Implement interactive elements: segment tap, swipe gestures, haptic feedback, animations
5. Add an "Add New Habit" row at the end of the list
6. Implement filter and sort functionality

### Test Strategie
1. Widget tests for HomeScreen layout and components
2. Widget tests for HabitRow interactions
3. Integration tests for swipe gestures and segment tapping
4. Test haptic feedback and animations
5. Test filter and sort functionality

### Subtasks

#### 4.1: Implement HomeScreen widget with TabBar navigation and habit ListView
- **Status:** ✅ done
- **Abhängigkeiten:** keine
- **Beschreibung:** Create the main HomeScreen widget with TabBar navigation and implement the vertical ListView for displaying habits.

**Implementierungsdetails (hinzugefügt 2025-10-26):**
- HomeScreen mit TabBar Navigation und HabitListView erstellt
- HabitListView mit Consumer<HabitProvider> Integration
- Empty State Handling mit Willkommensnachricht
- Unterstützende Widgets erstellt: HabitRow, AddNewHabitRow, SegmentedTimeline, WeekStripIndicator, StreakIndicator
- Umfassende Test-Suite mit 10 bestandenen Tests

#### 4.2: Implement HabitRow widget with segmented timeline and interactive elements
- **Status:** ✅ done
- **Abhängigkeiten:** 4.1
- **Beschreibung:** Create the HabitRow widget with icon/emoji, habit name, segmented timeline, streak indicator, and compact week strip.

**Implementierungsdetails (hinzugefügt 2025-10-26):**
- ProgressService für echte Datenintegration erstellt
- HabitRow auf ConsumerWidget mit Riverpod Providers umgestellt
- Echte Daten für currentValue und Streak-Berechnung integriert
- SegmentedTimeline mit onSegmentTap Callback aktualisiert
- WeekStripIndicator verwendet echte Wochen-Completion-Daten
- Alle Linting-Fehler behoben

#### 4.3: Implement interactive feedback and filter/sort functionality
- **Status:** ✅ done
- **Abhängigkeiten:** 4.1, 4.2
- **Beschreibung:** Add haptic feedback, animations for habit interactions, and implement filter and sort functionality for the habit list.

**Implementierungsdetails (hinzugefügt 2025-10-26):**
- Filter- und Sort-System implementiert
- HabitFilter Model mit umfassenden Filteroptionen erstellt
- HabitFilterController mit Riverpod für State Management
- Sortieroptionen hinzugefügt (due date, priority, manual, name, created date, streak)
- HabitFilterControls Widget mit Dropdowns erstellt
- Animations-System implementiert: Pop + Glow, Confetti für Streak-Inkremente

---

## Task 5: Implement habit creation and editing functionality

**Status:** ✅ done  
**Priorität:** high  
**Abhängigkeiten:** Task 2

### Beschreibung
Create the UI and logic for adding new habits and editing existing ones, including all required fields and recurrence options.

### Details
1. Create a HabitFormBottomSheet for both creating and editing habits
2. Implement form fields for all required habit properties
3. Implement recurrence pattern selection UI
4. Add validation for all fields
5. Connect form to HabitRepository for saving data
6. Use iOS-style bottom sheet with slide-up animation

### Test Strategie
1. Widget tests for HabitFormBottomSheet layout and components
2. Unit tests for form validation
3. Integration tests for saving habits
4. Test all recurrence pattern configurations
5. Test form initialization with existing habits

### Subtasks

#### 5.1: Implement basic form fields and validation
- **Status:** ✅ done
- **Abhängigkeiten:** keine
- **Beschreibung:** Create the HabitFormBottomSheet with all required form fields and implement validation logic for each field.

#### 5.2: Implement goal type and recurrence pattern selection
- **Status:** ✅ done
- **Abhängigkeiten:** 5.1
- **Beschreibung:** Create the UI components for selecting goal types (binary/quantitative) and recurrence patterns with all required options.

**Implementierungsdetails (hinzugefügt 2025-10-27):**
- GoalTypeSelectorWidget erstellt (Binary/Quantitative Auswahl)
- TargetValueWidget erstellt (Value Input + Unit Selection)
- RecurrenceSelectorWidget erstellt (Vollständige Recurrence Pattern Auswahl)
- HabitFormBottomSheet mit neuen Widgets aktualisiert
- Form Flow: Name → Icon → Color → Goal Type → (wenn Quantitative: Target Value + Unit) → Recurrence → Optional Note

#### 5.3: Connect form to data layer and implement saving functionality
- **Status:** ✅ done
- **Abhängigkeiten:** 5.1, 5.2
- **Beschreibung:** Implement the save functionality to connect the form with the HabitRepository and handle both creation and updating of habits.

---

## Task 6: Implement Statistics screen with analytics dashboard

**Status:** ⏱️ pending  
**Priorität:** medium  
**Abhängigkeiten:** Task 3

### Beschreibung
Create the Statistics screen with a dashboard layout showing streak highlights, week comparisons, 30-day trends, and a mini-heatmap.

### Details
1. Create a StatisticsScreen widget with a dashboard layout
2. Implement components: Streak highlight section, Week comparison, 30-day trend visualization, Mini-heatmap
3. Create data processing services to calculate statistics
4. Implement responsive layout for different screen sizes
5. Add empty/low-data states with encouraging messages

### Test Strategie
1. Widget tests for StatisticsScreen layout and components
2. Unit tests for statistics calculation logic
3. Integration tests for data visualization
4. Test empty/low-data states
5. Test with various data scenarios

### Subtasks

#### 6.1: Implement UI components for statistics dashboard
- **Status:** ⏱️ pending
- **Abhängigkeiten:** keine
- **Beschreibung:** Create the UI components for the statistics dashboard including streak highlights, week comparisons, 30-day trends, and mini-heatmap widgets.

#### 6.2: Create data processing services for statistics calculation
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 6.1
- **Beschreibung:** Develop services to process and calculate statistics data needed for the dashboard, including streak calculations, weekly comparisons, and trend analysis.

#### 6.3: Implement StatisticsScreen with responsive layout
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 6.1, 6.2
- **Beschreibung:** Create the main StatisticsScreen widget that integrates all components with a responsive layout and connects to the data services.

---

## Task 7: Implement Achievements screen with badges

**Status:** ⏱️ pending  
**Priorität:** medium  
**Abhängigkeiten:** Task 3

### Beschreibung
Create the Achievements screen with a grid layout displaying badges for various accomplishments, including unlocked and locked states.

### Details
1. Create an AchievementsScreen widget with a grid layout
2. Define badge categories: First Steps, Streak Milestones, Habit Management, Check-in Milestones, Perfection, Consistency
3. Implement badge unlocking logic
4. Create visual states for earned and locked badges
5. Add animations and feedback for badge unlocks

### Test Strategie
1. Widget tests for AchievementsScreen layout and components
2. Unit tests for achievement unlocking logic
3. Integration tests for badge interactions
4. Test animations and visual feedback
5. Test with various achievement states

### Subtasks

#### 7.1: Create AchievementsScreen with Grid Layout
- **Status:** ⏱️ pending
- **Abhängigkeiten:** keine
- **Beschreibung:** Implement the basic AchievementsScreen widget with a grid layout to display achievement badges.

#### 7.2: Implement Badge Card Component
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 7.1
- **Beschreibung:** Create the BadgeCard widget to display individual achievements with proper visual states for locked and unlocked badges.

#### 7.3: Implement Achievement Data Model and Provider
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 7.2
- **Beschreibung:** Create the Achievement data model and AchievementProvider to manage achievement states and unlocking logic.

---

## Task 8: Implement notification and reminder system

**Status:** ⏱️ pending  
**Priorität:** medium  
**Abhängigkeiten:** Task 2

### Beschreibung
Create a notification system that allows users to set up to 3 reminders per habit and handles snooze functionality.

### Details
1. Set up local notifications using flutter_local_notifications package
2. Create a ReminderService to manage notifications
3. Implement reminder creation and editing in the habit form
4. Add snooze functionality (+15 min, +1 hour)
5. Respect Do-Not-Disturb settings
6. Implement notification handling for different app states

### Test Strategie
1. Unit tests for ReminderService functionality
2. Widget tests for ReminderFormWidget
3. Integration tests for notification scheduling
4. Test snooze functionality
5. Test Do-Not-Disturb respect
6. Test notification handling in different app states

### Subtasks

#### 8.1: Set up local notifications infrastructure
- **Status:** ⏱️ pending
- **Abhängigkeiten:** keine
- **Beschreibung:** Implement the foundation for local notifications using flutter_local_notifications package and create the ReminderService class.

#### 8.2: Implement reminder creation and editing UI
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 8.1
- **Beschreibung:** Create the UI components for adding, editing, and managing up to 3 reminders per habit in the habit form.

#### 8.3: Implement snooze functionality and notification handling
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 8.1, 8.2
- **Beschreibung:** Add snooze options to notifications and handle notification interactions in different app states.

---

## Task 9: Implement onboarding flow

**Status:** ⏱️ pending  
**Priorität:** medium  
**Abhängigkeiten:** Task 2, Task 5

### Beschreibung
Create a guided iOS-style onboarding flow that helps users set up their first habit with a personalized, step-by-step approach in dark mode.

### Details
1. Create an OnboardingScreen with a segmented progress indicator
2. Implement 5 sequential steps: Welcome/Name, Habit Name, Icon + Color, Frequency, Notification permission
3. Design each screen with soft layout rhythm matching modern iOS setup flows
4. Add primary CTA buttons positioned above the safe area
5. Implement smooth transitions and microanimations between screens

### Test Strategie
1. Widget tests for OnboardingFlow layout and components
2. Integration tests for the complete 5-step onboarding flow
3. Test user input validation and persistence
4. Test habit creation with selected parameters
5. Test navigation between screens and progress tracking

### Subtasks

#### 9.1: Create OnboardingFlow widget structure
- **Status:** ⏱️ pending
- **Abhängigkeiten:** keine
- **Beschreibung:** Implement the base OnboardingFlow widget with PageView and progress indicator

#### 9.2: Implement Welcome/Name input screen
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.1
- **Beschreibung:** Create the first onboarding screen that welcomes users and collects their name

#### 9.3: Implement Habit Name input screen
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.1
- **Beschreibung:** Create the second screen that asks users what habit they want to build

#### 9.4: Implement Icon and Color selection screen
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.1
- **Beschreibung:** Create the third screen for selecting habit icon and color

#### 9.5: Implement Frequency selection screen
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.1
- **Beschreibung:** Create the fourth screen for selecting habit frequency

#### 9.6: Implement Notification permission screen
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.1
- **Beschreibung:** Create the final screen that explains the importance of notifications and requests permission

#### 9.7: Implement onboarding completion and habit creation
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.2, 9.3, 9.4, 9.5, 9.6
- **Beschreibung:** Create the logic to save user data and create the first habit when onboarding completes

#### 9.8: Implement animations and transitions
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.1, 9.2, 9.3, 9.4, 9.5, 9.6
- **Beschreibung:** Add smooth animations and transitions between onboarding screens

#### 9.9: Optimize for iOS dark mode
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 9.1, 9.2, 9.3, 9.4, 9.5, 9.6
- **Beschreibung:** Ensure all UI elements follow iOS dark mode guidelines and appearance

---

## Task 10: Implement animations and haptic feedback

**Status:** ⏱️ pending  
**Priorität:** low  
**Abhängigkeiten:** Task 1, Task 4, Task 6, Task 7

### Beschreibung
Add micro-animations, haptic feedback, and visual effects to enhance the user experience, including segment completion animations, streak increments, and badge unlocks.

### Details
1. Create animation utilities for common animations
2. Implement haptic feedback service
3. Add animations: Segment-Completion, Streak-Increment, Confetti, Badge-Unlock, Badge-Reveal, Trend-Updates, Streak-Expansion, Weekly-Gains, Data-Loading
4. Respect system settings for reduced motion

### Test Strategie
1. Unit tests for animation utilities
2. Widget tests for animation components
3. Integration tests for haptic feedback
4. Test animations with different durations and parameters
5. Test reduced motion settings compatibility

### Subtasks

#### 10.1: Create animation utilities for common animations
- **Status:** ⏱️ pending
- **Abhängigkeiten:** keine
- **Beschreibung:** Develop reusable animation utility classes that will be used across the app for consistent animation effects.

#### 10.2: Implement haptic feedback service
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 10.1
- **Beschreibung:** Create a service to manage haptic feedback throughout the app with different intensity levels for various user interactions.

#### 10.3: Integrate animations and haptic feedback with UI components
- **Status:** ⏱️ pending
- **Abhängigkeiten:** 10.1, 10.2
- **Beschreibung:** Apply the created animation utilities and haptic feedback to the appropriate UI components and user interactions throughout the app.

---

## Zusammenfassung

### Status Übersicht
- **Abgeschlossen:** 5 Tasks (Tasks 1-5)
- **Ausstehend:** 5 Tasks (Tasks 6-10)

### Gesamt Fortschritt
- **Tasks:** 5/10 abgeschlossen (50%)
- **Subtasks:** 13/33 abgeschlossen (39%)

### Nächste Schritte
Die nächsten prioritären Tasks sind:
1. **Task 6:** Statistics screen (medium priority)
2. **Task 7:** Achievements screen (medium priority)
3. **Task 8:** Notification system (medium priority)

