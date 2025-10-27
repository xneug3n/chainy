import 'package:flutter/material.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/recurrence_config.dart';
import '../../../../core/theme/chainy_colors.dart';

/// Widget for selecting recurrence patterns
class RecurrenceSelectorWidget extends StatefulWidget {
  final RecurrenceType recurrenceType;
  final RecurrenceConfig recurrenceConfig;
  final ValueChanged<RecurrenceType> onRecurrenceTypeChanged;
  final ValueChanged<RecurrenceConfig> onRecurrenceConfigChanged;

  const RecurrenceSelectorWidget({
    super.key,
    required this.recurrenceType,
    required this.recurrenceConfig,
    required this.onRecurrenceTypeChanged,
    required this.onRecurrenceConfigChanged,
  });

  @override
  State<RecurrenceSelectorWidget> createState() => _RecurrenceSelectorWidgetState();
}

class _RecurrenceSelectorWidgetState extends State<RecurrenceSelectorWidget> {
  late TextEditingController _intervalController;
  late TextEditingController _countController;
  late TextEditingController _targetCountController;
  
  List<Weekday> _selectedDays = [Weekday.monday, Weekday.tuesday, Weekday.wednesday, Weekday.thursday, Weekday.friday];
  DateTime? _selectedUntilDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _countController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _intervalController = TextEditingController(text: '1');
    _countController = TextEditingController();
    _targetCountController = TextEditingController(text: '3');

    // Initialize based on current config
    widget.recurrenceConfig.when(
      daily: (interval) => _intervalController.text = interval.toString(),
      multiplePerDay: (targetCount) => _targetCountController.text = targetCount.toString(),
      weekly: (daysOfWeek, interval) {
        _selectedDays = List.from(daysOfWeek);
        _intervalController.text = interval.toString();
      },
      custom: (interval, byDay, count, until) {
        _intervalController.text = interval.toString();
        if (byDay != null) _selectedDays = List.from(byDay);
        if (count != null) _countController.text = count.toString();
        _selectedUntilDate = until;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurrence',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ChainyColors.getPrimaryText(brightness),
          ),
        ),
        const SizedBox(height: 12),
        
        // Recurrence type selector
        _buildRecurrenceTypeSelector(brightness),
        
        const SizedBox(height: 16),
        
        // Configuration based on selected type
        _buildConfigurationSection(brightness),
      ],
    );
  }

  Widget _buildRecurrenceTypeSelector(Brightness brightness) {
    return Column(
      children: [
        _RecurrenceTypeOption(
          type: RecurrenceType.daily,
          title: 'Daily',
          subtitle: 'Every day',
          icon: Icons.calendar_today,
          isSelected: widget.recurrenceType == RecurrenceType.daily,
          onTap: () => _onRecurrenceTypeChanged(RecurrenceType.daily),
        ),
        const SizedBox(height: 8),
        _RecurrenceTypeOption(
          type: RecurrenceType.multiplePerDay,
          title: 'Multiple per day',
          subtitle: 'Several times daily',
          icon: Icons.repeat,
          isSelected: widget.recurrenceType == RecurrenceType.multiplePerDay,
          onTap: () => _onRecurrenceTypeChanged(RecurrenceType.multiplePerDay),
        ),
        const SizedBox(height: 8),
        _RecurrenceTypeOption(
          type: RecurrenceType.weekly,
          title: 'Weekly',
          subtitle: 'Specific days',
          icon: Icons.calendar_view_week,
          isSelected: widget.recurrenceType == RecurrenceType.weekly,
          onTap: () => _onRecurrenceTypeChanged(RecurrenceType.weekly),
        ),
        const SizedBox(height: 8),
        _RecurrenceTypeOption(
          type: RecurrenceType.custom,
          title: 'Custom',
          subtitle: 'Advanced pattern',
          icon: Icons.settings,
          isSelected: widget.recurrenceType == RecurrenceType.custom,
          onTap: () => _onRecurrenceTypeChanged(RecurrenceType.custom),
        ),
      ],
    );
  }

  Widget _buildConfigurationSection(Brightness brightness) {
    switch (widget.recurrenceType) {
      case RecurrenceType.daily:
        return _buildDailyConfig();
      case RecurrenceType.multiplePerDay:
        return _buildMultiplePerDayConfig();
      case RecurrenceType.weekly:
        return _buildWeeklyConfig();
      case RecurrenceType.custom:
        return _buildCustomConfig();
    }
  }

  Widget _buildDailyConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interval (days)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ChainyColors.getPrimaryText(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              final interval = int.tryParse(value) ?? 1;
              widget.onRecurrenceConfigChanged(RecurrenceConfig.daily(interval: interval));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultiplePerDayConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target count per day',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ChainyColors.getPrimaryText(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _targetCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '3',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              final count = int.tryParse(value) ?? 3;
              widget.onRecurrenceConfigChanged(RecurrenceConfig.multiplePerDay(targetCount: count));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Days of week',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ChainyColors.getPrimaryText(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Weekday.values.map((day) => _DayChip(
            day: day,
            isSelected: _selectedDays.contains(day),
            onTap: () => _toggleDay(day),
          )).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'Interval (weeks)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ChainyColors.getPrimaryText(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              final interval = int.tryParse(value) ?? 1;
              widget.onRecurrenceConfigChanged(RecurrenceConfig.weekly(
                daysOfWeek: _selectedDays,
                interval: interval,
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Days of week (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ChainyColors.getPrimaryText(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Weekday.values.map((day) => _DayChip(
            day: day,
            isSelected: _selectedDays.contains(day),
            onTap: () => _toggleDay(day),
          )).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interval',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ChainyColors.getPrimaryText(Theme.of(context).brightness),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _intervalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _updateCustomConfig(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Count (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ChainyColors.getPrimaryText(Theme.of(context).brightness),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '10',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _updateCustomConfig(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onRecurrenceTypeChanged(RecurrenceType type) {
    widget.onRecurrenceTypeChanged(type);
    
    // Set default config for new type
    switch (type) {
      case RecurrenceType.daily:
        widget.onRecurrenceConfigChanged(RecurrenceConfig.daily());
        break;
      case RecurrenceType.multiplePerDay:
        widget.onRecurrenceConfigChanged(RecurrenceConfig.multiplePerDay(targetCount: 3));
        break;
      case RecurrenceType.weekly:
        widget.onRecurrenceConfigChanged(RecurrenceConfig.weekly(
          daysOfWeek: _selectedDays,
        ));
        break;
      case RecurrenceType.custom:
        widget.onRecurrenceConfigChanged(RecurrenceConfig.custom(
          interval: 1,
          byDay: _selectedDays,
        ));
        break;
    }
  }

  void _toggleDay(Weekday day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
    _updateConfigForCurrentType();
  }

  void _updateCustomConfig() {
    final interval = int.tryParse(_intervalController.text) ?? 1;
    final count = int.tryParse(_countController.text);
    
    widget.onRecurrenceConfigChanged(RecurrenceConfig.custom(
      interval: interval,
      byDay: _selectedDays.isNotEmpty ? _selectedDays : null,
      count: count,
      until: _selectedUntilDate,
    ));
  }

  void _updateConfigForCurrentType() {
    switch (widget.recurrenceType) {
      case RecurrenceType.weekly:
        final interval = int.tryParse(_intervalController.text) ?? 1;
        widget.onRecurrenceConfigChanged(RecurrenceConfig.weekly(
          daysOfWeek: _selectedDays,
          interval: interval,
        ));
        break;
      case RecurrenceType.custom:
        _updateCustomConfig();
        break;
      default:
        break;
    }
  }
}

class _RecurrenceTypeOption extends StatelessWidget {
  final RecurrenceType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecurrenceTypeOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? ChainyColors.getAccentBlue(brightness).withOpacity(0.1)
              : ChainyColors.getCard(brightness),
          border: Border.all(
            color: isSelected 
                ? ChainyColors.getAccentBlue(brightness)
                : ChainyColors.getBorder(brightness),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected 
                  ? ChainyColors.getAccentBlue(brightness)
                  : ChainyColors.getSecondaryText(brightness),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ChainyColors.getPrimaryText(brightness),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ChainyColors.getSecondaryText(brightness),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 20,
                color: ChainyColors.getAccentBlue(brightness),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final Weekday day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? ChainyColors.getAccentBlue(brightness)
              : ChainyColors.getCard(brightness),
          border: Border.all(
            color: isSelected 
                ? ChainyColors.getAccentBlue(brightness)
                : ChainyColors.getBorder(brightness),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            _getDayAbbreviation(day),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected 
                  ? Colors.white
                  : ChainyColors.getPrimaryText(brightness),
            ),
          ),
        ),
      ),
    );
  }

  String _getDayAbbreviation(Weekday day) {
    switch (day) {
      case Weekday.monday: return 'M';
      case Weekday.tuesday: return 'T';
      case Weekday.wednesday: return 'W';
      case Weekday.thursday: return 'T';
      case Weekday.friday: return 'F';
      case Weekday.saturday: return 'S';
      case Weekday.sunday: return 'S';
    }
  }
}
