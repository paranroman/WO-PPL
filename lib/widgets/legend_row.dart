import 'package:flutter/material.dart';

class LegendRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  final Color? valueColor;

  const LegendRow({super.key,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((value / total) * 100).round();

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$pct%',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
