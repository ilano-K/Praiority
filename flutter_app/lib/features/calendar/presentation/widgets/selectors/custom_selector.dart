import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'date_picker.dart';

class CustomSelector extends StatefulWidget {
  final DateTime eventStartDate; 
  final int? initialInterval;
  final String? initialUnit;
  final Set<int>? initialDays;
  final String? initialEndOption;
  final DateTime? initialEndDate;
  final int? initialOccurrences;
  final String? initialMonthlyType;
  final TaskType taskType;

  const CustomSelector({
    super.key,
    required this.eventStartDate,
    this.initialInterval,
    this.initialUnit,
    this.initialDays,
    this.initialEndOption,
    this.initialEndDate,
    this.initialOccurrences,
    this.initialMonthlyType,
    this.taskType = TaskType.task,
  });

  @override
  State<CustomSelector> createState() => _CustomSelectorState();
}

class _CustomSelectorState extends State<CustomSelector> {
  late final TextEditingController _repeatController;
  late final TextEditingController _occurrenceController;
  
  late String _repeatUnit;
  late String _monthlyType;
  final List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  late Set<int> _selectedDays;
  late String _endOption;
  late DateTime _selectedEndDate;

  @override
  void initState() {
    super.initState();
    // For birthdays, default to yearly unit
    final isBirthday = widget.taskType == TaskType.birthday;
    
    _repeatController = TextEditingController(
      text: (widget.initialInterval ?? 1).toString()
    );
    
    _occurrenceController = TextEditingController(
      text: (widget.initialOccurrences ?? 1).toString()
    );
    
    _repeatUnit = isBirthday ? 'year' : (widget.initialUnit ?? 'day');
    _monthlyType = widget.initialMonthlyType ?? 'day';
    _selectedDays = widget.initialDays ?? {widget.eventStartDate.weekday % 7};
    _endOption = widget.initialEndOption ?? 'never';
    _selectedEndDate = widget.initialEndDate ?? widget.eventStartDate;
  }

  @override
  void dispose() {
    _repeatController.dispose();
    _occurrenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final referenceDate = widget.eventStartDate;
    final dayNum = referenceDate.day.toString();
    final dayName = DateFormat('EEEE').format(referenceDate);
    final weekNum = ((referenceDate.day - 1) / 7).floor() + 1;
    final ordinal = ["", "first", "second", "third", "fourth", "fifth"][weekNum];
    final isBirthday = widget.taskType == TaskType.birthday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: Icon(Icons.arrow_back_ios_new, color: colors.onSurface, size: 20),
              ),
              Text(
                "Custom Recurrence",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colors.onSurface),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'interval': int.tryParse(_repeatController.text) ?? 1,
                    'unit': _repeatUnit,
                    'days': _repeatUnit == 'week' ? _selectedDays : {widget.eventStartDate.weekday % 7},
                    'endOption': _endOption,
                    'endDate': _selectedEndDate,
                    'occurrences': int.tryParse(_occurrenceController.text) ?? 1,
                    'monthlyType': _monthlyType,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onSurface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 25),

          const SectionTitle(title: "Repeats Every"),
          Row(
            children: [
              TypeableBox(controller: _repeatController, width: 55),
              const SizedBox(width: 12),
              RepeatUnitDropdown(
                currentUnit: _repeatUnit,
                onUnitChanged: (val) => setState(() => _repeatUnit = val),
                isBirthdayOnly: isBirthday,
              ),
            ],
          ),
          
          if (_repeatUnit == 'week') ...[
            const SizedBox(height: 25),
            const SectionTitle(title: "Repeats on"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_days.length, (index) {
                final isSelected = _selectedDays.contains(index);
                return DayCircle(
                  label: _days[index],
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    if (isSelected) {
                      if (_selectedDays.length > 1) _selectedDays.remove(index);
                    } else {
                      _selectedDays.add(index);
                    }
                  }),
                );
              }),
            ),
          ] else if (_repeatUnit == 'month' && !isBirthday) ...[
            const SizedBox(height: 20),
            MonthlyTypeSelector(
              currentType: _monthlyType,
              dayNum: dayNum,
              ordinal: ordinal,
              dayName: dayName,
              onTypeChanged: (val) => setState(() => _monthlyType = val),
            ),
          ] else if (_repeatUnit == 'year') ...[
            const SizedBox(height: 20),
            StaticBox(text: "Every year on ${DateFormat('MMMM d').format(referenceDate)}"),
          ],

          const SizedBox(height: 25),

          if (!isBirthday) ...[
            const SectionTitle(title: "Ends"),
            EndRow(
              label: "Never",
              isSelected: _endOption == 'never',
              onTap: () => setState(() => _endOption = 'never'),
            ),
            EndRow(
              label: "On",
              isSelected: _endOption == 'on',
              onTap: () => setState(() => _endOption = 'on'),
              trailing: GestureDetector(
                onTap: () async {
                  setState(() => _endOption = 'on');
                  final date = await pickDate(context, initialDate: _selectedEndDate);
                  if (date != null) setState(() => _selectedEndDate = date);
                },
                child: StaticBox(text: DateFormat('MMM d, yyyy').format(_selectedEndDate)),
              ),
            ),
            EndRow(
              label: "After",
              isSelected: _endOption == 'after',
              onTap: () => setState(() => _endOption = 'after'),
              trailing: Row(
                children: [
                  TypeableBox(controller: _occurrenceController, width: 50),
                  const SizedBox(width: 10),
                  Text("occurrence(s)", style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
//           REUSABLE UI COMPONENTS
// ==========================================

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colors.onSurface),
      ),
    );
  }
}

class TypeableBox extends StatelessWidget {
  final TextEditingController controller;
  final double width;
  const TypeableBox({super.key, required this.controller, required this.width});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: 45,
      decoration: BoxDecoration(
        color: colors.primary,
        border: Border.all(color: colors.onSurface, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
        decoration: const InputDecoration(
          border: InputBorder.none, 
          contentPadding: EdgeInsets.zero
        ),
      ),
    );
  }
}

class StaticBox extends StatelessWidget {
  final String text;
  const StaticBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary,
        border: Border.all(color: colors.onSurface, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
    );
  }
}

class RepeatUnitDropdown extends StatelessWidget {
  final String currentUnit;
  final ValueChanged<String> onUnitChanged;
  final bool isBirthdayOnly;
  
  const RepeatUnitDropdown({
    super.key, 
    required this.currentUnit, 
    required this.onUnitChanged,
    this.isBirthdayOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final availableUnits = isBirthdayOnly ? ["year"] : ["day", "week", "month", "year"];
    
    return PopupMenuButton<String>(
      onSelected: onUnitChanged,
      itemBuilder: (context) => availableUnits
          .map((u) => PopupMenuItem(
                value: u, 
                child: Text(u, style: TextStyle(fontWeight: currentUnit == u ? FontWeight.bold : FontWeight.normal))
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.onSurface, width: 1.2), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
            Text(currentUnit, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: colors.onSurface),
          ],
        ),
      ),
    );
  }
}

class MonthlyTypeSelector extends StatelessWidget {
  final String currentType, dayNum, ordinal, dayName;
  final ValueChanged<String> onTypeChanged;
  const MonthlyTypeSelector({
    super.key, 
    required this.currentType, 
    required this.dayNum, 
    required this.ordinal, 
    required this.dayName, 
    required this.onTypeChanged
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      onSelected: onTypeChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.onSurface, width: 1.2), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                currentType == 'day' 
                  ? "Monthly on day $dayNum" 
                  : "Monthly on the $ordinal $dayName", 
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)
              )
            ),
            Icon(Icons.arrow_drop_down, color: colors.onSurface),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'day', child: Text("Monthly on day $dayNum")),
        PopupMenuItem(value: 'position', child: Text("Monthly on the $ordinal $dayName")),
      ],
    );
  }
}

class DayCircle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const DayCircle({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 48, alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          border: Border.all(color: colors.onSurface, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: colors.onSurface)),
      ),
    );
  }
}

class EndRow extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final Widget? trailing;
  const EndRow({super.key, required this.isSelected, required this.onTap, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap, 
            child: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off, 
              color: colors.onSurface, 
              size: 28
            )
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface)),
          const SizedBox(width: 12),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}