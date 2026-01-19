import 'package:flutter/material.dart';

class AiTipWidget extends StatelessWidget {
  final String description;
  final VoidCallback? onClose;

  const AiTipWidget({
    Key? key,
    required this.description,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Set a fixed width or remove for full width
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allows the column to shrink-wrap its children
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Tip',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            softWrap: true, // Ensures text wraps to the next line
            overflow: TextOverflow.visible, // Allows the container to expand
          ),
        ],
      ),
    );
  }
}

// Example Usage:
//
// AiTipWidget(
//   description: 'This is a short description.',
//   onClose: () {
//     // Handle close action
//   },
// )
//
// AiTipWidget(
//   description: 'This is a much longer description that will cause the widget to expand vertically to fit all the text. It demonstrates the dynamic resizing capability.',
//   onClose: () {
//     // Handle close action
//   },
// )