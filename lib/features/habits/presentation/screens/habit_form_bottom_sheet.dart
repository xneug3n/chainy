import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/habit.dart';
import '../../../../core/ui/chainy_button.dart';
import '../../../../core/ui/chainy_text_field.dart';
import '../../../../core/theme/chainy_colors.dart';
import '../widgets/icon_selector_widget.dart';
import '../widgets/color_picker_widget.dart';

/// iOS-style bottom sheet for creating and editing habits
class HabitFormBottomSheet extends StatefulWidget {
  final Habit? habit; // Null for new habit, non-null for editing
  
  const HabitFormBottomSheet({
    super.key,
    this.habit,
  });
  
  @override
  State<HabitFormBottomSheet> createState() => _HabitFormBottomSheetState();
}

class _HabitFormBottomSheetState extends State<HabitFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  
  String _selectedIcon = '📝';
  Color _selectedColor = ChainyColors.lightAccentBlue;
  String? _nameError;
  
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
      _selectedColor = widget.habit!.color;
    } else {
      // Initialize with default values
      _nameController = TextEditingController();
      _noteController = TextEditingController();
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
                  text: 'Save',
                  variant: ChainyButtonVariant.text,
                  onPressed: _saveHabit,
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
                  // Name field
                  ChainyTextField(
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
                  
                  const SizedBox(height: 24),
                  
                  // Icon selector
                  IconSelectorWidget(
                    selectedIcon: _selectedIcon,
                    onIconSelected: (icon) => setState(() => _selectedIcon = icon),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Color picker
                  ColorPickerWidget(
                    selectedColor: _selectedColor,
                    onColorSelected: (color) => setState(() => _selectedColor = color),
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
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveHabit() {
    // Validate form
    if (!_validateForm()) {
      return;
    }
    
    // TODO: Implement save functionality in subtask 5.3
    // For now, just close the bottom sheet
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
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
