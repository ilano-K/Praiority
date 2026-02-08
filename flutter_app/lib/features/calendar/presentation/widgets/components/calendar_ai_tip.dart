  import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'dart:async';

  // Import your Smart Features Controller
  import 'package:flutter_app/features/calendar/presentation/managers/smart_features_controller.dart';

  class AiTipWidget extends ConsumerStatefulWidget {
    final String taskId; // 1. Added ID so we know what task to ask about
    final String title;
    final String description;
    final String generatedTip; // Initial tip (if any)
    final bool isCompleted;
    final VoidCallback onEdit;
    final VoidCallback? onComplete;
    final VoidCallback onDelete;

    const AiTipWidget({
      super.key,
      required this.taskId, 
      required this.title,
      required this.description,
      required this.generatedTip,
      required this.onEdit,
      this.onComplete,
      required this.onDelete,
      this.isCompleted = false,
    });

    @override
    ConsumerState<AiTipWidget> createState() => _AiTipWidgetState();
  }

  class _AiTipWidgetState extends ConsumerState<AiTipWidget> {
    bool _isGenerating = false;
    bool _tipReceived = false;
    String _loadingDots = "";
    Timer? _timer;
    
    // 2. Local variable to hold the tip (starts with the one passed in)
    late String _currentTip;

    @override
    void initState() {
      super.initState();
      _currentTip = widget.generatedTip;
      // If we already have a tip passed in, mark it as received
      if (_currentTip.isNotEmpty) {
        _tipReceived = true;
      }
    }

    // 3. THE REAL LOGIC
    Future<void> _generateTip() async {
      // Start Animation
      setState(() {
        _isGenerating = true;
        _loadingDots = "";
      });

      // Start the "..." animation timer just for visuals
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
        setState(() {
          if (_loadingDots.length >= 3) {
            _loadingDots = "";
          } else {
            _loadingDots += ".";
          }
        });
      });

      try {
        // CALL THE CONTROLLER
        // We pass the task ID and a default instruction
        final newAdvice = await ref.read(calendarControllerProvider.notifier).requestAiTip(
          widget.taskId
        );

        if (mounted) {
          setState(() {
            _isGenerating = false;
            _tipReceived = true;
            // Update the text with the real result
            _currentTip = newAdvice ?? "Could not generate advice.";
          });
          _timer?.cancel();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isGenerating = false;
            _currentTip = "Error: Failed to connect to AI.";
            _tipReceived = true;
          });
          _timer?.cancel();   
        }
      }
    }

    @override
    void dispose() {
      _timer?.cancel();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 28, color: colorScheme.onSurface),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 22, color: colorScheme.onSurface),
                      onPressed: widget.onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (widget.onComplete != null) const SizedBox(width: 10),
                    if (widget.onComplete != null)
                      GestureDetector(
                        onTap: widget.onComplete,
                        child: Container(
                          width: 28, 
                          height: 28,
                          decoration: BoxDecoration(
                            color: widget.isCompleted ? colorScheme.primary : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.onSurface, 
                              width: 1.5,
                            ),
                          ),
                          child: widget.isCompleted 
                            ? Icon(Icons.check, size: 18, color: colorScheme.onSurface) 
                            : null,
                        ),
                      )
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            // 2. TITLE & DESCRIPTION
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                decoration: widget.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                decoration: widget.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            const SizedBox(height: 30),

            // 3. GENERATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Connect the button to the real function
                onPressed: _isGenerating ? null : _generateTip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onSurface,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _tipReceived ? "Regenerate AI Tip" : "Generate AI Tip",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            // 4. ANIMATED DOTS OR GENERATED TIP
            if (_isGenerating || _tipReceived) const SizedBox(height: 20),
            
            if (_isGenerating)
              Text(
                _loadingDots,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            
            if (_tipReceived && !_isGenerating)
              Text(
                _currentTip, // Display the dynamic variable
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
                softWrap: true,
              ),
          ],
        ),
      );
    }
  }