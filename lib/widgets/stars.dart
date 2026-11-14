import 'package:flutter/material.dart';

class Stars extends StatelessWidget {
  const Stars({
    super.key,
    required this.value,
    this.size = 16,
    this.showValue = true,
  });

  final double? value;
  final double size;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Text(
        'No ratings yet',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    final rounded = value!.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = rounded >= i + 1;
          final half = !filled && rounded >= i + 0.5;
          return Icon(
            filled
                ? Icons.star
                : half
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: const Color(0xFFF59E0B),
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rounded.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class StarInput extends StatelessWidget {
  const StarInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        return IconButton(
          onPressed: () => onChanged(n),
          icon: Icon(
            n <= value ? Icons.star : Icons.star_border,
            color: const Color(0xFFF59E0B),
          ),
        );
      }),
    );
  }
}
