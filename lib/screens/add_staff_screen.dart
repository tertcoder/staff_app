import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/api_service.dart';

class AddStaffScreen extends StatefulWidget {
  final StaffMember? staff; // Null means add mode

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
    _status = staff?.status ?? 'active';
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
        id: widget.staff?.id ?? '', // Keep existing ID for edits
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
                  ? 'Staff added successfully!'
                  : 'Staff updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: Text(widget.staff == null ? "Add Staff" : "Edit Staff"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              const SizedBox(height: 16),

              // Position Field
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: "Position"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Department Dropdown
              DropdownButtonFormField<String>(
                value: _department,
                items:
                    const [
                          'Administration',
                          'Finance',
                          'Académique',
                          'Ressources Humaines',
                          'Maintenance',
                        ]
                        .map(
                          (dept) =>
                              DropdownMenuItem(value: dept, child: Text(dept)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _department = value!),
                decoration: const InputDecoration(labelText: "Department"),
              ),
              const SizedBox(height: 16),

              // Salary Field
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: "Salary"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'on_leave', child: Text('On Leave')),
                ],
                onChanged: (value) => setState(() => _status = value!),
                decoration: const InputDecoration(labelText: "Status"),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _saveStaff,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SAVE STAFF"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
