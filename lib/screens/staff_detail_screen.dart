import 'package:staff_app/models/staff.dart';
import 'package:staff_app/screens/add_staff_screen.dart';
import 'package:staff_app/services/api_service.dart';
import 'package:flutter/material.dart';

class StaffDetailScreen extends StatelessWidget {
  final StaffMember staff;

  const StaffDetailScreen({super.key, required this.staff});

  Color _getStatusColor(String status) {
    switch (status) {
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

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Supprimer un membre',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${staff.name} ? Cette action est irréversible.',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteStaff(context);
    }
  }

  Future<void> _deleteStaff(BuildContext context) async {
    try {
      // Afficher l'indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          );
        },
      );

      await ApiService.deleteStaff(staff.id);

      if (context.mounted) {
        // Masquer l'indicateur de chargement
        Navigator.of(context).pop();

        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${staff.name} supprimé avec succès'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Retour à l'écran d'accueil avec résultat
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        // Masquer l'indicateur de chargement
        Navigator.of(context).pop();

        // Afficher le message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la suppression : ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStaffScreen(staff: staff),
                      ),
                    ).then((result) {
                      if (result == true) {
                        // Données mises à jour, retour à l'écran d'accueil
                        Navigator.pop(context, true);
                      }
                    }),
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded),
                onPressed: () => _showDeleteDialog(context),
                color: const Color(0xFFEF4444),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: 'avatar_${staff.id}',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
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
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        staff.position,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Carte Statut
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _getStatusColor(staff.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(
                        staff.status,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        staff.status == 'actif'
                            ? Icons.check_circle_rounded
                            : staff.status == 'en_conge'
                            ? Icons.beach_access_rounded
                            : Icons.cancel_rounded,
                        color: _getStatusColor(staff.status),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Statut : ${staff.status.split('_').where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(staff.status),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cartes Détails
                _buildDetailCard(
                  Icons.email_rounded,
                  "Adresse Email",
                  staff.email,
                  const Color(0xFF3B82F6),
                ),
                _buildDetailCard(
                  Icons.phone_rounded,
                  "Numéro de téléphone",
                  staff.phone,
                  const Color(0xFF10B981),
                ),
                _buildDetailCard(
                  Icons.business_center_rounded,
                  "Département",
                  staff.department,
                  const Color(0xFF8B5CF6),
                ),
                _buildDetailCard(
                  Icons.calendar_today_rounded,
                  "Date d'embauche",
                  "${staff.hireDate.day}/${staff.hireDate.month}/${staff.hireDate.year}",
                  const Color(0xFFF59E0B),
                ),
                _buildDetailCard(
                  Icons.attach_money_rounded,
                  "Salaire",
                  "${staff.salary.toStringAsFixed(2)} €",
                  const Color(0xFFEF4444),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
