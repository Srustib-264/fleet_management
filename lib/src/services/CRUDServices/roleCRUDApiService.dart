import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/roleCRUDModel.dart';
import '../apiUrl.dart';

class RoleCRUDAPIService {
  Future<RoleCRUDModel> getRoles() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse(BaseURLConfig.rolesApiURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return RoleCRUDModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load roles: ${response.statusCode}');
    }
  }

  Future<RoleData> getRoleById(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('${BaseURLConfig.rolesApiURL}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return RoleData.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load role: ${response.statusCode}');
    }
  }

  Future<bool> createRole({
    required int roleCode,
    required String roleName,
    required String description,
    required int hierarchyLevel,
    required bool isSystemRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken') ?? '';

    final body = {
      'role_code': roleCode,
      'role_name': roleName,
      'description': description,
      'hierarchy_level': hierarchyLevel,
      'is_system_role': isSystemRole,
    };

    final response = await http.post(
      Uri.parse(BaseURLConfig.rolesApiURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateRole({
    required String id,
    required int roleCode,
    required String roleName,
    required String description,
    required int hierarchyLevel,
    required bool isSystemRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken') ?? '';

    final body = {
      'role_code': roleCode,
      'role_name': roleName,
      'description': description,
      'hierarchy_level': hierarchyLevel,
      'is_system_role': isSystemRole,
    };

    final response = await http.put(
      Uri.parse('${BaseURLConfig.rolesApiURL}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteRole(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken') ?? '';

    final response = await http.delete(
      Uri.parse('${BaseURLConfig.rolesApiURL}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
