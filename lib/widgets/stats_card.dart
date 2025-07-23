import 'package:flutter/material.dart';

class EnhancedStatsCard extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final LinearGradient gradient;

  const EnhancedStatsCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white.withValues(alpha: 0.9)),
            const Spacer(),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
