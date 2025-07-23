import 'package:flutter/material.dart';
import 'package:staff_app/models/staff.dart';
import 'package:staff_app/screens/staff_detail_screen.dart';

class EnhancedStaffCard extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onDataChanged;

  const EnhancedStaffCard({
    super.key,
    required this.staff,
    required this.onDelete,
    required this.onEdit,
    this.onDataChanged,
  });

  Color _getStatusColor() {
    switch (staff.status) {
      case 'actif':
        return const Color(0xFF10B981);
      case 'inactif':
        return const Color(0xFFEF4444);
      case 'en_conge':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel() {
    switch (staff.status) {
      case 'actif':
        return 'Actif';
      case 'inactif':
        return 'Inactif';
      case 'en_conge':
        return 'En congé';
      default:
        return staff.status
            .split('_')
            .map((s) {
              return s[0].toUpperCase() + s.substring(1);
            })
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap:
              () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          StaffDetailScreen(staff: staff),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ).then((result) {
                if (result == true && onDataChanged != null) {
                  onDataChanged!();
                }
              }),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar amélioré
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.8),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      staff.name
                          .split(' ')
                          .where((n) => n.isNotEmpty)
                          .map((n) => n[0].toUpperCase())
                          .take(2)
                          .join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Informations du membre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.position,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        staff.department,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Statut et actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor().withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_rounded),
                          color: const Color(0xFF6366F1),
                          iconSize: 20,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_rounded),
                          color: const Color(0xFFEF4444),
                          iconSize: 20,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
