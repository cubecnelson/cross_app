import 'package:flutter/material.dart';
import '../core/constants/ontherack_constants.dart';

class AvailabilityPill extends StatelessWidget {
  const AvailabilityPill({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final meta = availabilityMeta(value);
    final Color color = switch (meta.value) {
      'PLENTY' => const Color(0xFF10B981),
      'SOME_WAIT' => const Color(0xFFF59E0B),
      'CROWDED' => const Color(0xFFEF4444),
      'OUT_OF_SERVICE' => const Color(0xFF6B7280),
      _ => Theme.of(context).colorScheme.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        meta.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
