import 'package:flutter/material.dart';

/// The only representation of a visit's photo outside the gated viewer.
///
/// Per ui-plan §3.1/3.4: a locked placeholder — icon + lock badge. It never
/// decodes or renders the actual image file, so gated content has exactly one
/// entry point (the photo viewer, Phase 7).
class LockedPhotoPlaceholder extends StatelessWidget {
  const LockedPhotoPlaceholder({super.key, this.dimensions = 40});

  final double dimensions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: dimensions,
      height: dimensions,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(child: Icon(Icons.photo, size: dimensions * 0.6, color: scheme.onSurfaceVariant)),
          Positioned(
            right: 2,
            bottom: 2,
            child: Icon(Icons.lock, size: dimensions * 0.35, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}