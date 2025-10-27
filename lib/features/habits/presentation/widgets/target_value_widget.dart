import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/chainy_text_field.dart';
import '../../../../core/theme/chainy_colors.dart';

/// Widget for setting target value and unit for quantitative goals
class TargetValueWidget extends StatefulWidget {
  final int targetValue;
  final String unit;
  final ValueChanged<int> onTargetValueChanged;
  final ValueChanged<String> onUnitChanged;

  const TargetValueWidget({
    super.key,
    required this.targetValue,
    required this.unit,
    required this.onTargetValueChanged,
    required this.onUnitChanged,
  });

  @override
  State<TargetValueWidget> createState() => _TargetValueWidgetState();
}

class _TargetValueWidgetState extends State<TargetValueWidget> {
  late TextEditingController _valueController;
  late TextEditingController _unitController;
  String? _valueError;

  final List<String> _commonUnits = [
    'times',
    'minutes',
    'hours',
    'pages',
    'glasses',
    'steps',
    'calories',
    'km',
    'miles',
    'lbs',
    'kg',
  ];

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.targetValue.toString());
    _unitController = TextEditingController(text: widget.unit);
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ChainyColors.getPrimaryText(brightness),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ChainyTextField(
                label: 'Value',
                hint: '1',
                controller: _valueController,
                errorText: _valueError,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if (_valueError != null) {
                    setState(() => _valueError = null);
                  }
                  final intValue = int.tryParse(value);
                  if (intValue != null && intValue > 0) {
                    widget.onTargetValueChanged(intValue);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ChainyTextField(
                label: 'Unit',
                hint: 'times',
                controller: _unitController,
                textInputAction: TextInputAction.done,
                onChanged: widget.onUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _commonUnits.map((unit) => _UnitChip(
            unit: unit,
            isSelected: widget.unit == unit,
            onTap: () {
              _unitController.text = unit;
              widget.onUnitChanged(unit);
            },
          )).toList(),
        ),
      ],
    );
  }

}

class _UnitChip extends StatelessWidget {
  final String unit;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitChip({
    required this.unit,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? ChainyColors.getAccentBlue(brightness)
              : ChainyColors.getCard(brightness),
          border: Border.all(
            color: isSelected 
                ? ChainyColors.getAccentBlue(brightness)
                : ChainyColors.getBorder(brightness),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: isSelected 
                ? Colors.white
                : ChainyColors.getPrimaryText(brightness),
          ),
        ),
      ),
    );
  }
}
