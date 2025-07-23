import 'package:staff_app/models/staff.dart';
import 'package:staff_app/services/api_service.dart';
import 'package:flutter/material.dart';

class AddStaffScreen extends StatefulWidget {
  final StaffMember? staff;

  const AddStaffScreen({super.key, this.staff});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _salaryController;
  late String _department;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final staff = widget.staff;
    _nameController = TextEditingController(text: staff?.name ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _phoneController = TextEditingController(text: staff?.phone ?? '');
    _positionController = TextEditingController(text: staff?.position ?? '');
    _salaryController = TextEditingController(
      text: staff?.salary.toStringAsFixed(2) ?? '',
    );
    _department = staff?.department ?? 'Administration';
    _status = staff?.status ?? 'actif';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final staff = StaffMember(
        id: widget.staff?.id ?? '',
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        position: _positionController.text,
        department: _department,
        hireDate: widget.staff?.hireDate ?? DateTime.now(),
        salary: double.tryParse(_salaryController.text) ?? 0,
        status: _status,
      );

      if (widget.staff == null) {
        await ApiService.addStaff(staff);
      } else {
        await ApiService.updateStaff(staff.id, staff);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.staff == null
                  ? 'Membre du personnel ajouté avec succès !'
                  : 'Membre du personnel mis à jour avec succès !',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.staff == null ? "Ajouter un membre" : "Modifier le membre",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Section Avatar
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                            .split(' ')
                            .where((n) => n.isNotEmpty)
                            .map((n) => n[0].toUpperCase())
                            .take(2)
                            .join()
                        : "?",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Champ Nom
            _buildEnhancedTextField(
              controller: _nameController,
              label: "Nom complet",
              icon: Icons.person_rounded,
              validator: (value) => value!.isEmpty ? "Le nom est requis" : null,
            ),

            const SizedBox(height: 20),

            // Champ Email
            _buildEnhancedTextField(
              controller: _emailController,
              label: "Adresse email",
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) return "L'email est requis";
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return "Veuillez entrer un email valide";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Champ Téléphone
            _buildEnhancedTextField(
              controller: _phoneController,
              label: "Numéro de téléphone",
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            // Champ Poste
            _buildEnhancedTextField(
              controller: _positionController,
              label: "Poste occupé",
              icon: Icons.work_rounded,
              validator:
                  (value) => value!.isEmpty ? "Le poste est requis" : null,
            ),

            const SizedBox(height: 20),

            // Menu Département
            _buildEnhancedDropdown(
              value: _department,
              label: "Département",
              icon: Icons.business_center_rounded,
              items: const [
                "Administration",
                "Finance",
                "Académique",
                "Ressources Humaines",
                "Maintenance",
              ],
              onChanged: (value) => setState(() => _department = value!),
            ),

            const SizedBox(height: 20),

            // Champ Salaire
            _buildEnhancedTextField(
              controller: _salaryController,
              label: "Salaire annuel",
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return "Le salaire est requis";
                if (double.tryParse(value) == null) {
                  return "Veuillez entrer un nombre valide";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Menu Statut
            _buildEnhancedDropdown(
              value: _status,
              label: "Statut d'emploi",
              icon: Icons.flag_rounded,
              items: const ['actif', 'inactif', 'en_conge'],
              itemLabels: const ['Actif', 'Inactif', 'En congé'],
              onChanged: (value) => setState(() => _status = value!),
            ),

            const SizedBox(height: 40),

            // Bouton de sauvegarde
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveStaff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.staff == null
                                  ? Icons.add_rounded
                                  : Icons.save_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.staff == null
                                  ? "AJOUTER UN MEMBRE"
                                  : "METTRE À JOUR",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        onChanged: (value) {
          if (controller == _nameController) {
            setState(() {}); // Rebuild pour mettre à jour l'avatar
          }
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        ),
      ),
    );
  }

  Widget _buildEnhancedDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    List<String>? itemLabels,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final displayLabel =
                  itemLabels?[index] ??
                  item
                      .split('_')
                      .map((word) => word[0].toUpperCase() + word.substring(1))
                      .join(' ');

              return DropdownMenuItem(value: item, child: Text(displayLabel));
            }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        ),
      ),
    );
  }
}
