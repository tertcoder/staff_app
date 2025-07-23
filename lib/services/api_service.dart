import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/staff.dart';

class ApiService {
  // static String get _baseUrl {
  //   // Detect if running on Android emulator
  //   // 10.0.2.2 is used for Android emulator to access host machine
  //   // For physical device, use your actual host IP (e.g., 192.168.x.x)
  //   const emulatorUrl = "http://10.0.2.2:5000/api/staff";
  //   const deviceUrl =
  //       "http://192.168.0.112:5000/api/staff"; // Change to your host IP

  //   // Check for Android emulator environment variable
  //   // This is a simple heuristic; adjust as needed for your setup
  //   if (const String.fromEnvironment('FLUTTER_TEST') == 'true' ||
  //       !bool.fromEnvironment('dart.vm.product')) {
  //     return emulatorUrl;
  //   }
  //   return deviceUrl;
  // }

  static const _baseUrl = "http://192.168.194.126:5000/api/staff";

  static Future<List<StaffMember>> getStaff({
    String? search,
    String? filter,
  }) async {
    print('BASE URL: $_baseUrl');
    final response = await http.get(
      Uri.parse("$_baseUrl?search=${search ?? ''}&status=${filter ?? 'all'}"),
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => StaffMember.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load staff');
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse("$_baseUrl/stats"));
    return json.decode(response.body);
  }

  static Future<StaffMember> addStaff(StaffMember staff) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': staff.name,
        'email': staff.email,
        'phone': staff.phone,
        'position': staff.position,
        'department': staff.department,
        'hireDate': staff.hireDate.toIso8601String(),
        'salary': staff.salary,
        'status': staff.status,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return StaffMember.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add staff member: ${response.body}');
    }
  }

  static Future<void> updateStaff(String id, StaffMember staff) async {
    final response = await http.put(
      Uri.parse("$_baseUrl/$id"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': staff.name,
        'email': staff.email,
        'phone': staff.phone,
        'position': staff.position,
        'department': staff.department,
        'hireDate': staff.hireDate.toIso8601String(),
        'salary': staff.salary,
        'status': staff.status,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update staff');
    }
  }

  static Future<void> deleteStaff(String id) async {
    await http.delete(Uri.parse("$_baseUrl/$id"));
  }

  static Future<void> deleteAllStaff() async {
    final response = await http.delete(Uri.parse('$_baseUrl/delete-all'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete all staff');
    }
  }

  static Future<String> exportStaffToExcel() async {
    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/staff_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      await dio.download(
        '$_baseUrl/export/excel',
        path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      return path;
    } catch (e) {
      throw Exception('Failed to export: ${e.toString()}');
    }
  }

  static Future<int> importStaffFromExcel(File file) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'staff_import.xlsx',
        ),
      });

      final response = await dio.post('$_baseUrl/import/excel', data: formData);

      return response.data['importedCount'] as int;
    } catch (e) {
      throw Exception('Failed to import: ${e.toString()}');
    }
  }
}
