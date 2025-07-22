class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final String department;
  final DateTime hireDate;
  final double salary;
  final String status;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.hireDate,
    required this.salary,
    required this.status,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      department: json['department'],
      hireDate: DateTime.parse(json['hireDate']),
      salary: json['salary'].toDouble(),
      status: json['status'],
    );
  }
}
