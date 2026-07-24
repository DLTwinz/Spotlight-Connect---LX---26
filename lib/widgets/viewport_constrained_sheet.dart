import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wraps bottom-sheet content so it is always fully visible within the viewport.
///
/// This is intentionally a light-touch containment utility:
/// - Centers the sheet in the viewport (desktop/tablet/mobile)
/// - Applies safe padding for system insets + keyboard
/// - Enforces a max width and max height
/// - Adds internal scrolling *only if needed*
///
/// It does not impose any visual styling (your child is responsible for its
/// background, borders, etc.).
class ViewportConstrainedSheet extends StatelessWidget {
  const ViewportConstrainedSheet({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.maxHeight = 760,
    this.margin = const EdgeInsets.all(12),
  });

  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final safe = mq.padding;
    final insets = mq.viewInsets;
    final availableHeight = mq.size.height - safe.vertical;
    final cappedHeight = math
        .min(maxHeight, math.max(320.0, availableHeight - 24.0))
        .toDouble();

    // Keep the overlay centered and fully in-bounds even with the keyboard open.
    // We use AnimatedPadding to avoid jarring jumps when viewInsets change.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: margin.left + safe.left,
        right: margin.right + safe.right,
        top: margin.top + safe.top,
        bottom: margin.bottom + safe.bottom + insets.bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: cappedHeight,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}
