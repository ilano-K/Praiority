import 'package:flutter/material.dart';

class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final List<String> availableTags;
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
  final Set<String> _tagsToDelete = {};
  String _searchQuery = "";
  bool _isSearching = false; 

  bool get _isDeleting => _tagsToDelete.isNotEmpty;
  bool get _canSearch => widget.availableTags.length >= 6;

  void _toggleTag(String tag) {
    if (widget.selectedTags.contains(tag)) {
      widget.onTagsChanged([]);
    } else {
      widget.onTagsChanged([tag]);
    }
  }

  void _toggleDeleteSelection(String tag) {
    setState(() {
      if (_tagsToDelete.contains(tag)) {
        _tagsToDelete.remove(tag);
      } else {
        _tagsToDelete.add(tag);
      }
    });
  }

  void _handleBulkDelete() {
    for (var tag in _tagsToDelete) {
      widget.onTagRemoved(tag);
    }
    setState(() {
      _tagsToDelete.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filteredTags = widget.availableTags
        .where((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // --- DYNAMIC SIZE LOGIC ---
      // We use BoxConstraints so it stays small when empty, grows to 5, 
      // and locks at 6+ to enable scrolling.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrinks to content size
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme),
          const SizedBox(height: 10),
          const Divider(thickness: 1),

          if (widget.availableTags.isNotEmpty)
            Flexible( // Flexible allows the list to grow until it hits the maxHeight
              child: ListView.builder(
                shrinkWrap: true, // Crucial: allows the list to only take the space it needs
                itemCount: filteredTags.length,
                itemBuilder: (context, index) {
                  return _buildOption(context, filteredTags[index], colorScheme);
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: ListTile(
              onTap: () => _showAddDialog(context),
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.add, size: 24, color: colorScheme.onSurface),
              title: Text(
                "Add tag",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    if (_isDeleting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Delete ${_tagsToDelete.length} tags?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _tagsToDelete.clear()),
                child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface)),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: colorScheme.error),
                onPressed: _handleBulkDelete,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!_isSearching)
          Text(
            "Select Tag",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
          ),
        
        if (_isSearching)
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              cursorColor: colorScheme.onSurface,
              autofocus: true,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search Tag",
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: () => setState(() {
                    _isSearching = false;
                    _searchQuery = "";
                  }),
                ),
                border: InputBorder.none,
              ),
            ),
          ),

        if (!_isSearching && _canSearch)
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.onSurface),
            onPressed: () => setState(() => _isSearching = true),
          ),
        
        if (!_isSearching && !_canSearch)
          const SizedBox(height: 48), 
      ],
    );
  }

  Widget _buildOption(BuildContext context, String label, ColorScheme colorScheme) {
    bool isSelected = widget.selectedTags.contains(label);
    bool isMarkedForDeletion = _tagsToDelete.contains(label);

    return ListTile(
      onTap: () {
        if (_isDeleting) {
          _toggleDeleteSelection(label);
        } else {
          _toggleTag(label);
        }
      },
      onLongPress: () => _toggleDeleteSelection(label),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _isDeleting
            ? (isMarkedForDeletion ? Icons.check_box : Icons.check_box_outline_blank)
            : (isSelected ? Icons.check_circle : Icons.circle_outlined),
        size: 24,
        color: _isDeleting && isMarkedForDeletion 
            ? colorScheme.error 
            : (isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5)),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: _isDeleting 
        ? null 
        : IconButton(
            icon: Icon(Icons.delete_outline, size: 22, color: colorScheme.onSurface),
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
        title: Text("New Tag", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          cursorColor: colorScheme.onSurface,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Enter tag name",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold))
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.onTagAdded(controller.text);
                _toggleTag(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text("Add", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}