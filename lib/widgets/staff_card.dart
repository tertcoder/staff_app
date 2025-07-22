import 'package:flutter/material.dart';
import 'package:staff_app/screens/staff_detail_screen.dart';
import '../models/staff.dart';

class StaffCard extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const StaffCard({
    super.key,
    required this.staff,
    required this.onDelete,
    required this.onEdit,
  });

  Color _getStatusColor() {
    switch (staff.status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'on_leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffDetailScreen(staff: staff),
              ),
            ),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF3B4B5B),
          child: Text(
            staff.name
                .split(' ')
                .where((n) => n.isNotEmpty)
                .map((n) => n[0].toUpperCase())
                .take(2)
                .join(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(staff.name),
        subtitle: Text("${staff.position} • ${staff.department}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(staff.status.toUpperCase()),
              backgroundColor: _getStatusColor().withValues(alpha: 0.2),
              labelStyle: TextStyle(color: _getStatusColor()),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
