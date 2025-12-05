import 'package:flutter/material.dart';

class TagSelector extends StatefulWidget {
  final String currentTag;
  final List<String> availableTags; 
  final ValueChanged<String> onTagSelected;
  final ValueChanged<String> onTagAdded; 
  final ValueChanged<String> onTagRemoved; // <--- NEW: Delete Callback

  const TagSelector({
    super.key,
    required this.currentTag,
    required this.availableTags,
    required this.onTagSelected,
    required this.onTagAdded,
    required this.onTagRemoved, // <--- Require this
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
            "Select Tag", // <--- CHANGED TITLE
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
        color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      // --- TRAILING: Checkmark + Delete Button ---
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) 
            Icon(Icons.check, color: colorScheme.primary),
          
          // The X Button to delete
          IconButton(
            icon: Icon(Icons.close, size: 20, color: colorScheme.onSurface.withOpacity(0.5)),
            onPressed: () {
              // Call the delete callback
              widget.onTagRemoved(label);
            },
          ),
        ],
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
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Enter tag name",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary),
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