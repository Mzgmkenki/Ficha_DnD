import 'package:flutter/material.dart';

class DerivedValueRow extends StatelessWidget {
  const DerivedValueRow({
    required this.label,
    required this.value,
    this.proficient = false,
    super.key,
  });

  final String label;
  final int value;
  final bool proficient;

  @override
  Widget build(BuildContext context) {
    final display = value >= 0 ? '+$value' : '$value';

    return Row(
      children: [
        Icon(
          proficient ? Icons.check_circle : Icons.circle_outlined,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(
          display,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}