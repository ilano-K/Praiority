// lib/src/shared/widgets/selectors/custom_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/repeat_selector.dart';
import 'package:intl/intl.dart';

class CustomSelector extends StatefulWidget {
  const CustomSelector({super.key});

  @override
  State<CustomSelector> createState() => _CustomSelectorState();
}

class _CustomSelectorState extends State<CustomSelector> {
  // --- STATE VARIABLES ---
  final TextEditingController _repeatController = TextEditingController(text: '1');
  final TextEditingController _occurrenceController = TextEditingController(text: '1');
  
  String _repeatUnit = 'day';
  String _monthlyType = 'day'; // 'day' or 'position'
  final List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final Set<int> _selectedDays = {1}; // Default to Monday
  String _endOption = 'never'; 
  DateTime _selectedEndDate = DateTime(2026, 2, 3);

  @override
  void dispose() {
    _repeatController.dispose();
    _occurrenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Logic for Monthly labels based on the selected start date
    // For this example, we'll use today as the reference point
    final now = DateTime.now();
    final dayNum = now.day.toString();
    final dayName = DateFormat('EEEE').format(now);
    final weekNum = ((now.day - 1) / 7).floor() + 1;
    final ordinal = ["", "first", "second", "third", "fourth", "fifth"][weekNum];

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
          // --- HEADER SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      barrierDismissible: true,
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, _, __) => Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Align(
                          alignment: Alignment.bottomCenter,
                          child: RepeatSelector(
                            currentRepeat: "Custom",
                            onRepeatSelected: (val) {}, 
                          ),
                        ),
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          )),
                          child: child,
                        );
                      },
                    ),
                  );
                },
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
                    'days': _selectedDays,
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

          // --- REPEATS EVERY ---
          _buildSectionTitle("Repeats Every", colors),
          Row(
            children: [
              _buildTypeableBox(_repeatController, 50, colors),
              const SizedBox(width: 12),
              _buildDropdown(colors),
            ],
          ),
          
          // ✅ --- CONDITIONAL MONTHLY OPTION ---
          if (_repeatUnit == 'month') ...[
            const SizedBox(height: 20),
            _buildMonthlyTypeSelector(colors, dayNum, ordinal, dayName),
          ],
          
          const SizedBox(height: 25),

          // --- CONDITIONAL REPEATS ON (WEEKLY) ---
          if (_repeatUnit == 'week') ...[
            _buildSectionTitle("Repeats on", colors),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_days.length, (index) {
                final isSelected = _selectedDays.contains(index);
                return _buildDayCircle(_days[index], isSelected, index, colors);
              }),
            ),
            const SizedBox(height: 25),
          ],

          // --- ENDS ---
          _buildSectionTitle("Ends", colors),
          
          _buildEndRow(
            isSelected: _endOption == 'never',
            onTap: () => setState(() => _endOption = 'never'),
            label: "Never",
            colors: colors,
          ),

          _buildEndRow(
            isSelected: _endOption == 'on',
            onTap: () => setState(() => _endOption = 'on'),
            label: "On",
            colors: colors,
            trailing: GestureDetector(
              onTap: () async {
                setState(() => _endOption = 'on');
                final date = await pickDate(context, initialDate: _selectedEndDate);
                if (date != null) {
                  setState(() => _selectedEndDate = date);
                }
              },
              child: _buildStaticBox(
                DateFormat('MMMM d, yyyy').format(_selectedEndDate), 
                colors,
              ),
            ),
          ),

          _buildEndRow(
            isSelected: _endOption == 'after',
            onTap: () => setState(() => _endOption = 'after'),
            label: "After",
            colors: colors,
            trailing: Row(
              children: [
                _buildTypeableBox(_occurrenceController, 50, colors),
                const SizedBox(width: 10),
                Text("occurrence", style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER UI WIDGETS ---

  Widget _buildMonthlyTypeSelector(ColorScheme colors, String dayNum, String ordinal, String dayName) {
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _monthlyType = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.onSurface, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _monthlyType == 'day' 
                  ? "Monthly on day $dayNum" 
                  : "Monthly on the $ordinal $dayName",
              style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            const SizedBox(width: 8),
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

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colors.onSurface),
      ),
    );
  }

  Widget _buildTypeableBox(TextEditingController controller, double width, ColorScheme colors) {
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
        cursorColor: colors.onSurface,
        style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildStaticBox(String text, ColorScheme colors) {
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

  Widget _buildDropdown(ColorScheme colors) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _repeatUnit = value;
        });
      },
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.onSurface, width: 1.2),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildPopupItem("day", colors),
        _buildPopupItem("week", colors),
        _buildPopupItem("month", colors),
        _buildPopupItem("year", colors),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.onSurface, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              _repeatUnit,
              style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: colors.onSurface),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, ColorScheme colors) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: TextStyle(
          fontWeight: _repeatUnit == value ? FontWeight.bold : FontWeight.normal,
          color: colors.onSurface,
        ),
      ),
    );
  }

  Widget _buildDayCircle(String label, bool isSelected, int index, ColorScheme colors) {
    return GestureDetector(
      onTap: () => setState(() {
        isSelected ? _selectedDays.remove(index) : _selectedDays.add(index);
      }),
      child: Container(
        width: 42,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          border: Border.all(color: colors.onSurface, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w900, color: colors.onSurface),
        ),
      ),
    );
  }

  Widget _buildEndRow({
    required bool isSelected, 
    required VoidCallback onTap, 
    required String label, 
    required ColorScheme colors, 
    Widget? trailing
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: colors.onSurface,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label, 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface)
          ),
          const SizedBox(width: 12),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}