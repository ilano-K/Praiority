import 'package:flutter/material.dart';

class TagSelector extends StatefulWidget {
  final String currentTag;
  final List<String> availableTags; 
  final ValueChanged<String> onTagSelected;
  final ValueChanged<String> onTagAdded; 
  final ValueChanged<String> onTagRemoved; 

  const TagSelector({
    super.key,
    required this.currentTag,
    required this.availableTags,
    required this.onTagSelected,
    required this.onTagAdded,
    required this.onTagRemoved, 
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Tag", 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface, 
            ),
          ),
          const SizedBox(height: 15),
          
          // --- SCROLLABLE LIST ---
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...widget.availableTags.map((tag) => _buildOption(context, tag)),
                ],
              ),
            ),
          ),

          const Divider(),

          // --- ADD NEW BUTTON ---
          ListTile(
            onTap: () => _showAddDialog(context),
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary, 
              radius: 16,
              child: Icon(Icons.add, size: 20, color: colorScheme.onSurface),
            ),
            title: Text(
              "Add new tag",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom), 
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label) {
    bool isSelected = widget.currentTag == label;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () {
        widget.onTagSelected(label);
        Navigator.pop(context);
      },
      leading: Icon(
        Icons.label_outline, 
        // Icon is Black (onSurface) if selected, faded if not
        color: isSelected ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.5),
      ),
      title: Text(
        label,
        style: TextStyle(
          // Text is Bold if selected
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // Text is always Black (onSurface)
          color: colorScheme.onSurface,
        ),
      ),
      // --- TRAILING: Only Delete Button (No Checkmark) ---
      trailing: IconButton(
        icon: Icon(Icons.close, size: 20, color: colorScheme.onSurface.withOpacity(0.5)),
        onPressed: () {
          widget.onTagRemoved(label);
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    TextEditingController customTagController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("New Tag", style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: customTagController,
          autofocus: true,
          // 1. Text is onSurface (Black)
          style: TextStyle(color: colorScheme.onSurface),
          // 2. Cursor is onSurface (Black)
          cursorColor: colorScheme.onSurface,
          decoration: InputDecoration(
            hintText: "Enter tag name",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
            // 3. Focused Line is onSurface (Black)
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onSurface),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () {
              if (customTagController.text.isNotEmpty) {
                widget.onTagAdded(customTagController.text);
                widget.onTagSelected(customTagController.text);
                Navigator.pop(context); 
                Navigator.pop(context); 
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, 
              foregroundColor: Colors.black, 
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}