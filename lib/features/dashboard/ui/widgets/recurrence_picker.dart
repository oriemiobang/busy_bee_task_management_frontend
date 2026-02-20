import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class RecurrencePicker extends StatefulWidget {
  final String? initialType;
  final int? initialInterval;
  final List<String>? initialDays;
  final ValueChanged<Map<String, dynamic>> onRecurrenceChanged;

  const RecurrencePicker({
    super.key,
    this.initialType = 'ONCE',
    this.initialInterval,
    this.initialDays,
    required this.onRecurrenceChanged,
  });

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  String _recurrenceType = 'ONCE';
  int _interval = 1;
  List<String> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    _recurrenceType = widget.initialType ?? 'ONCE';
    _interval = widget.initialInterval ?? 1;
    _selectedDays = widget.initialDays ?? [];
  }

  void _showRecurrenceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF151A23),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Repeat Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Recurrence type selector
              _buildRecurrenceTypeSelector(),
              
              // Interval selector (conditional)
              if (_recurrenceType != 'ONCE' && _recurrenceType != 'YEARLY') ...[
                const SizedBox(height: 16),
                _buildIntervalSelector(),
              ],
              
              // Days selector (weekly only)
              if (_recurrenceType == 'WEEKLY') ...[
                const SizedBox(height: 16),
                _buildDaysSelector(),
              ],
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onRecurrenceChanged({
                          'type': _recurrenceType,
                          if (_recurrenceType != 'ONCE') 'interval': _interval,
                          if (_recurrenceType == 'WEEKLY') 'days': _selectedDays,
                          if (_recurrenceType == 'MONTHLY') 'dayOfMonth': _interval,
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceTypeSelector() {
    final types = [
      {'value': 'ONCE', 'label': 'Does not repeat', 'icon': Icons.radio_button_unchecked},
      {'value': 'DAILY', 'label': 'Daily', 'icon': Icons.today},
      {'value': 'WEEKLY', 'label': 'Weekly', 'icon': Icons.calendar_view_week},
      {'value': 'MONTHLY', 'label': 'Monthly', 'icon': Icons.calendar_month},
      {'value': 'YEARLY', 'label': 'Yearly', 'icon': Icons.calendar_today},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...types.map((type) => RadioListTile<String>(
          value: type['value'] as String,
          groupValue: _recurrenceType,
          onChanged: (value) {
            setState(() {
              _recurrenceType = value!;
              if (value == 'ONCE') _selectedDays.clear();
            });
          },
          title: Text(
            type['label'] as String,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          secondary: Icon(
            type['icon'] as IconData,
            color: _recurrenceType == type['value'] 
                ? AppColors.primary 
                : Colors.grey,
          ),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        )),
      ],
    );
  }

  Widget _buildIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _recurrenceType == 'MONTHLY' 
              ? 'Day of month' 
              : 'Every X ${_recurrenceType.toLowerCase().substring(0, _recurrenceType.length-2)}(s)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: () {
                setState(() {
                  _interval = _interval > 1 ? _interval - 1 : 1;
                });
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _recurrenceType == 'MONTHLY' 
                        ? '${_interval}' 
                        : '$_interval',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  _interval = _interval < 31 ? _interval + 1 : 31;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaysSelector() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select days',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(days.length, (index) {
            final day = days[index];
            final isSelected = _selectedDays.contains(day);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(day);
                  } else {
                    _selectedDays.add(day);
                  }
                });
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[700]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        if (_selectedDays.isNotEmpty)
          Text(
            'Selected: ${_selectedDays.length} day${_selectedDays.length > 1 ? 's' : ''}',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showRecurrenceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color.fromARGB(55, 100, 200, 255),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.repeat,
                color: Color.fromARGB(154, 100, 200, 255),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recurrence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getRecurrenceLabel(),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getRecurrenceLabel() {
    if (_recurrenceType == 'ONCE') return 'Does not repeat';
    if (_recurrenceType == 'DAILY') return 'Every $_interval day${_interval > 1 ? 's' : ''}';
    if (_recurrenceType == 'WEEKLY') {
      if (_selectedDays.isEmpty) return 'Every week';
      final days = _selectedDays.map((d) => d.substring(0, 1)).join(', ');
      return 'Every $_interval week${_interval > 1 ? 's' : ''} on $days';
    }
    if (_recurrenceType == 'MONTHLY') return 'Day $_interval of every month';
    if (_recurrenceType == 'YEARLY') return 'Every year';
    return 'Custom recurrence';
  }
}