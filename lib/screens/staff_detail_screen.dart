import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/api_service.dart';
import 'add_staff_screen.dart';

class StaffDetailScreen extends StatelessWidget {
  final StaffMember staff;

  const StaffDetailScreen({super.key, required this.staff});

  Color _getStatusColor(String status) {
    switch (status) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(staff.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddStaffScreen(), // Reuse add screen for edit
                    // Pass existing staff data here (needs modification in AddStaffScreen)
                  ),
                ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ApiService.deleteStaff(staff.id);
              navigator.pop(true); // Return 'true' to trigger refresh
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF3B4B5B),
                child: Text(
                  staff.name
                      .split(' ')
                      .where((n) => n.isNotEmpty)
                      .map((n) => n[0].toUpperCase())
                      .take(2)
                      .join(),
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildDetailRow(Icons.email, "Email", staff.email),
            _buildDetailRow(Icons.phone, "Phone", staff.phone),
            _buildDetailRow(Icons.work, "Position", staff.position),
            _buildDetailRow(Icons.business, "Department", staff.department),
            _buildDetailRow(
              Icons.calendar_today,
              "Hire Date",
              "${staff.hireDate.day}/${staff.hireDate.month}/${staff.hireDate.year}",
            ),
            _buildDetailRow(
              Icons.attach_money,
              "Salary",
              "${staff.salary.toStringAsFixed(2)} €",
            ),
            Chip(
              label: Text(
                staff.status.toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(staff.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2ECC71)),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
