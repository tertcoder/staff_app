import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 10),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
