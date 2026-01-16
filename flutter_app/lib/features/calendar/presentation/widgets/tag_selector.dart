import 'package:flutter/material.dart';

class TagSelector extends StatefulWidget {
  // 1. Change currentTag to a List
  final List<String> selectedTags; 
  final List<String> availableTags;
  // 2. Change callback to return the full updated list
  final ValueChanged<List<String>> onTagsChanged;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.availableTags,
    required this.onTagsChanged,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  
  // Helper to toggle a tag in the list
  void _toggleTag(String tag) {
    List<String> updatedTags = List.from(widget.selectedTags);
    if (updatedTags.contains(tag)) {
      updatedTags.remove(tag);
    } else {
      updatedTags.add(tag);
    }
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // Slightly taller for multi-select
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme),
          const SizedBox(height: 15),
          
          _buildInteractiveRow(colorScheme),
          
          const Divider(),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.availableTags.length,
              itemBuilder: (context, index) {
                return _buildOption(context, widget.availableTags[index]);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: ListTile(
              onTap: () => _showAddDialog(context),
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                radius: 16,
                child: Icon(Icons.add, size: 20, color: colorScheme.onSecondaryContainer),
              ),
              title: Text(
                "Add new tag",
                style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Select Tags",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        // Add a "Done" button since we no longer pop automatically
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Done"),
        )
      ],
    );
  }

  Widget _buildInteractiveRow(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.availableTags.map((tag) {
          bool isSelected = widget.selectedTags.contains(tag);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip( // Changed ChoiceChip to FilterChip
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => _toggleTag(tag),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label) {
    bool isSelected = widget.selectedTags.contains(label);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () => _toggleTag(label),
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.close, size: 20, color: colorScheme.error.withOpacity(0.7)),
        onPressed: () => widget.onTagRemoved(label),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: const Text("New Tag"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter tag name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.onTagAdded(controller.text);
                _toggleTag(controller.text); // Automatically select the new tag
                Navigator.pop(context); 
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}