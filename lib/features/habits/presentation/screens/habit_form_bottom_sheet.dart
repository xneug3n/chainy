import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/recurrence_config.dart';
import '../../../../core/ui/chainy_button.dart';
import '../../../../core/ui/chainy_text_field.dart';
import '../../../../core/theme/chainy_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../widgets/icon_selector_widget.dart';
import '../widgets/goal_type_selector_widget.dart';
import '../widgets/target_value_widget.dart';
import '../widgets/recurrence_selector_widget.dart';
import '../widgets/reminder_form_widget.dart';
import '../../domain/models/reminder.dart';
import '../controllers/habit_controller.dart';

/// iOS-style bottom sheet for creating and editing habits
class HabitFormBottomSheet extends ConsumerStatefulWidget {
  final Habit? habit; // Null for new habit, non-null for editing
  
  const HabitFormBottomSheet({
    super.key,
    this.habit,
  });
  
  @override
  ConsumerState<HabitFormBottomSheet> createState() => _HabitFormBottomSheetState();
}

class _HabitFormBottomSheetState extends ConsumerState<HabitFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  
  String _selectedIcon = '📝';
  GoalType _goalType = GoalType.binary;
  int _targetValue = 1;
  String _unit = 'times';
  RecurrenceType _recurrenceType = RecurrenceType.daily;
  late RecurrenceConfig _recurrenceConfig;
  String? _nameError;
  bool _isSaving = false;
  String? _saveError;
  List<Reminder> _reminders = [];
  
  @override
  void initState() {
    super.initState();
    _initializeFormValues();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  void _initializeFormValues() {
    if (widget.habit != null) {
      // Initialize with existing habit values
      _nameController = TextEditingController(text: widget.habit!.name);
      _noteController = TextEditingController(text: widget.habit!.note ?? '');
      _selectedIcon = widget.habit!.icon;
      _goalType = widget.habit!.goalType;
      _targetValue = widget.habit!.targetValue;
      _unit = widget.habit!.unit ?? 'times';
      _recurrenceType = widget.habit!.recurrenceType;
      _recurrenceConfig = widget.habit!.recurrenceConfig;
      _reminders = List.from(widget.habit!.reminders);
    } else {
      // Initialize with default values
      _nameController = TextEditingController();
      _noteController = TextEditingController();
      _recurrenceConfig = const RecurrenceConfig.daily();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: ChainyColors.getBackground(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: ChainyColors.getSecondaryText(brightness),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChainyButton(
                  text: 'Cancel',
                  variant: ChainyButtonVariant.text,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  widget.habit == null ? 'New Habit' : 'Edit Habit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ChainyColors.getPrimaryText(brightness),
                  ),
                ),
                ChainyButton(
                  text: _isSaving ? 'Saving...' : 'Save',
                  variant: ChainyButtonVariant.text,
                  onPressed: _isSaving ? null : _saveHabit,
                ),
              ],
            ),
          ),
          
          Divider(
            color: ChainyColors.getBorder(brightness),
            height: 1,
          ),
          
          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Error message (if any)
                  if (_saveError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _saveError!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => setState(() => _saveError = null),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Name field with icon selector
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon selector box (aligned with text field)
                      Padding(
                        padding: const EdgeInsets.only(top: 28), // Align with text field (label height + spacing)
                        child: IconSelectorWidget(
                          selectedIcon: _selectedIcon,
                          onIconSelected: (icon) => setState(() => _selectedIcon = icon),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name field (expanded to fill remaining space)
                      Expanded(
                        child: ChainyTextField(
                          label: 'Habit Name',
                          hint: 'Enter habit name',
                          controller: _nameController,
                          errorText: _nameError,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Goal type selector
                  GoalTypeSelectorWidget(
                    goalType: _goalType,
                    onGoalTypeChanged: (type) => setState(() => _goalType = type),
                  ),
                  
                  // Target value and unit (for quantitative goals)
                  if (_goalType == GoalType.quantitative) ...[
                    const SizedBox(height: 24),
                    TargetValueWidget(
                      targetValue: _targetValue,
                      unit: _unit,
                      onTargetValueChanged: (value) => setState(() => _targetValue = value),
                      onUnitChanged: (value) => setState(() => _unit = value),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Recurrence selector
                  RecurrenceSelectorWidget(
                    recurrenceType: _recurrenceType,
                    recurrenceConfig: _recurrenceConfig,
                    onRecurrenceTypeChanged: (type) => setState(() => _recurrenceType = type),
                    onRecurrenceConfigChanged: (config) => setState(() => _recurrenceConfig = config),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Note field
                  ChainyTextField(
                    label: 'Note (Optional)',
                    hint: 'Add a note about this habit',
                    controller: _noteController,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Reminders section
                  ReminderFormWidget(
                    habitId: widget.habit?.id ?? 'temp',
                    existingReminders: _reminders,
                    onRemindersChanged: (reminders) {
                      setState(() {
                        _reminders = reminders;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveHabit() async {
    final startTime = DateTime.now();
    AppLogger.separator('HABIT SAVE OPERATION', tag: 'HabitForm');
    
    // Collect form data for logging
    final formData = {
      'isEdit': widget.habit != null,
      'existingHabitId': widget.habit?.id,
      'name': _nameController.text.trim(),
      'icon': _selectedIcon,
      'goalType': _goalType.toString(),
      'targetValue': _targetValue,
      'unit': _unit.isEmpty ? null : _unit,
      'recurrenceType': _recurrenceType.toString(),
      'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    };
    
    AppLogger.functionEntry('_saveHabit', params: formData, tag: 'HabitForm');
    
    // Validate form
    AppLogger.debug('Validating form', tag: 'HabitForm');
    if (!_validateForm()) {
      AppLogger.warning('Form validation failed', tag: 'HabitForm');
      return;
    }
    AppLogger.info('Form validation passed', tag: 'HabitForm');
    
    // Clear any previous errors
    setState(() {
      _saveError = null;
      _isSaving = true;
    });
    
    try {
      AppLogger.debug('Reading habitControllerProvider', tag: 'HabitForm');
      final habitController = ref.read(habitControllerProvider.notifier);
      AppLogger.debug('HabitController obtained successfully', tag: 'HabitForm');
      
      if (widget.habit == null) {
        // Creating a new habit
        AppLogger.info('Creating new habit', tag: 'HabitForm');
        AppLogger.debug('Calling createHabit with parameters', data: formData, tag: 'HabitForm');
        
        final newHabitId = DateTime.now().millisecondsSinceEpoch.toString();
        final now = DateTime.now();
        
        // Update reminder habitIds to match the new habit
        final remindersWithHabitId = _reminders.map((r) => r.copyWith(habitId: newHabitId)).toList();
        
        final newHabit = Habit(
          id: newHabitId,
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: ChainyColors.lightAccentBlue,
          goalType: _goalType,
          targetValue: _targetValue,
          unit: _unit.isEmpty ? null : _unit,
          recurrenceType: _recurrenceType,
          recurrenceConfig: _recurrenceConfig,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          reminders: remindersWithHabitId,
          createdAt: now,
          updatedAt: now,
        );
        
        await habitController.updateHabit(newHabit);
        
        AppLogger.info('createHabit completed successfully', tag: 'HabitForm');
      } else {
        // Updating an existing habit
        AppLogger.info('Updating existing habit', data: {'habitId': widget.habit!.id}, tag: 'HabitForm');
        
        final updatedHabit = widget.habit!.copyWith(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          goalType: _goalType,
          targetValue: _targetValue,
          unit: _unit.isEmpty ? null : _unit,
          recurrenceType: _recurrenceType,
          recurrenceConfig: _recurrenceConfig,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          reminders: _reminders,
          updatedAt: DateTime.now(),
        );
        
        AppLogger.debug('Updated habit object created', data: updatedHabit.toJson(), tag: 'HabitForm');
        AppLogger.debug('Calling updateHabit', tag: 'HabitForm');
        
        await habitController.updateHabit(updatedHabit);
        
        AppLogger.info('updateHabit completed successfully', tag: 'HabitForm');
      }
      
      // Success feedback and navigation
      AppLogger.info('Save operation successful, closing bottom sheet', tag: 'HabitForm');
      if (mounted) {
        // Reset saving state
        setState(() {
          _isSaving = false;
        });
        
        // Provide haptic feedback
        HapticFeedback.lightImpact();
        
        // Close the bottom sheet and return to home screen
        Navigator.of(context).pop(true); // Return true to indicate success
      }
      
      final duration = DateTime.now().difference(startTime);
      AppLogger.functionExit('_saveHabit', tag: 'HabitForm', duration: duration);
      AppLogger.info('✅ Habit save operation completed successfully', 
        data: {'duration': '${duration.inMilliseconds}ms'}, tag: 'HabitForm');
    } catch (error, stack) {
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.error(
        'Habit save operation failed',
        error: error,
        stackTrace: stack,
        tag: 'HabitForm',
        context: {
          'formData': formData,
          'duration': '${duration.inMilliseconds}ms',
          'mounted': mounted,
          'isEditMode': widget.habit != null,
        },
      );
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = 'Failed to save habit: ${error.toString()}';
        });
        HapticFeedback.heavyImpact();
      }
      
      AppLogger.functionExit('_saveHabit', tag: 'HabitForm', duration: duration);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        AppLogger.debug('Save operation finalized, isSaving set to false', tag: 'HabitForm');
      }
    }
  }
  
  bool _validateForm() {
    bool isValid = true;
    
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Please enter a habit name');
      isValid = false;
    } else if (_nameController.text.trim().length > 50) {
      setState(() => _nameError = 'Habit name must be 50 characters or less');
      isValid = false;
    }
    
    return isValid;
  }
}

/// Helper function to show the bottom sheet
void showHabitFormBottomSheet(BuildContext context, {Habit? habit}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => HabitFormBottomSheet(habit: habit),
  );
}
