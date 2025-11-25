import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final String? label;
  final TextStyle? labelStyle;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant;
    final progColor = progressColor ?? Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: labelStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progColor),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(value * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: progColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}