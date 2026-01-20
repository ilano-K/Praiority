// File: lib/features/calendar/presentation/widgets/ai_tip_widget.dart
import 'package:flutter/material.dart';
import 'dart:async';

class AiTipWidget extends StatefulWidget {
  final String title;
  final String description;
  final String generatedTip;
  final bool isCompleted;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const AiTipWidget({
    super.key,
    required this.title,
    required this.description,
    required this.generatedTip,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
    this.isCompleted = false,
  });

  @override
  State<AiTipWidget> createState() => _AiTipWidgetState();
}

class _AiTipWidgetState extends State<AiTipWidget> {
  bool _isGenerating = false;
  bool _tipReceived = false;
  String _loadingDots = "";
  Timer? _timer;

  void _startLoadingAnimation() {
    setState(() {
      _isGenerating = true;
      _tipReceived = false;
      _loadingDots = "";
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        if (_loadingDots == "...") {
          _loadingDots = "";
        } else {
          _loadingDots += ".";
        }
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _tipReceived = true;
        });
      }
    });
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
        // Uses Background color (Light: FFFFFF, Dark: 0C0C0C)
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
                // Uses Icon color (Light: 000000, Dark: FFFFFF)
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
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: widget.onComplete,
                    child: Container(
                      width: 28, 
                      height: 28,
                      decoration: BoxDecoration(
                        // The fill uses the primary "action" color from your scheme
                        color: widget.isCompleted ? colorScheme.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          // Border uses onSurface (Light: 000000, Dark: FFFFFF)
                          color: colorScheme.onSurface, 
                          width: 1.5,
                        ),
                      ),
                      child: widget.isCompleted 
                        ? Icon(
                            Icons.check, 
                            size: 18, 
                            // Using onSurface ensures the checkmark matches your 
                            // Icon/Text color (Black in Light, White in Dark)
                            color: colorScheme.onSurface, 
                          ) 
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
              onPressed: _isGenerating ? null : _startLoadingAnimation,
              style: ElevatedButton.styleFrom(
                // Uses Button color (Light: B0C8F5, Dark: 333459)
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
          
          if (_tipReceived)
            Text(
              widget.generatedTip,
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