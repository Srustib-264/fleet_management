import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/groupCRUDModel.dart';
import '../apiUrl.dart';

class GroupApiService {
  // ============================================================
  // GET ALL GROUPS
  // ============================================================

  Future<GroupCRUDModel> getGroups() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse(BaseURLConfig.groupCRUDApiService),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('GET GROUPS STATUS: ${response.statusCode}');

      print('GET GROUPS RESPONSE: ${response.body}');

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200) {
        return GroupCRUDModel.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch groups');
      }
    } catch (e) {
      throw Exception('Error fetching groups: $e');
    }
  }

  // ============================================================
  // CREATE GROUP
  // ============================================================

  Future<void> createGroup(Map<String, dynamic> groupData) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.post(
        Uri.parse(BaseURLConfig.groupCRUDApiService),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(groupData),
      );

      print('CREATE GROUP STATUS: ${response.statusCode}');

      print('CREATE GROUP RESPONSE: ${response.body}');

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      // --------------------------------------------------------
      // HANDLE VALIDATION ERRORS
      // --------------------------------------------------------

      if (responseData['errors'] is List) {
        final errors = responseData['errors'] as List;

        final messages = errors
            .map((error) {
              return error['msg']?.toString() ?? 'Invalid field';
            })
            .join('\n');

        throw Exception(messages);
      }

      throw Exception(responseData['message'] ?? 'Failed to create group');
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  // ============================================================
  // UPDATE GROUP
  // ============================================================

  Future<void> updateGroup(
    String groupId,
    Map<String, dynamic> groupData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.put(
        Uri.parse('${BaseURLConfig.groupCRUDApiService}/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(groupData),
      );

      print('UPDATE GROUP STATUS: ${response.statusCode}');

      print('UPDATE GROUP RESPONSE: ${response.body}');

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      }

      // --------------------------------------------------------
      // HANDLE VALIDATION ERRORS
      // --------------------------------------------------------

      if (responseData['errors'] is List) {
        final errors = responseData['errors'] as List;

        final messages = errors
            .map((error) {
              return error['msg']?.toString() ?? 'Invalid field';
            })
            .join('\n');

        throw Exception(messages);
      }

      throw Exception(responseData['message'] ?? 'Failed to update group');
    } catch (e) {
      throw Exception('Error updating group: $e');
    }
  }

  // ============================================================
  // DELETE GROUP
  // ============================================================

  Future<void> deleteGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.delete(
        Uri.parse('${BaseURLConfig.groupCRUDApiService}/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('DELETE GROUP STATUS: ${response.statusCode}');

      print('DELETE GROUP RESPONSE: ${response.body}');

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      // --------------------------------------------------------
      // HANDLE VALIDATION ERRORS
      // --------------------------------------------------------

      if (responseData['errors'] is List) {
        final errors = responseData['errors'] as List;

        final messages = errors
            .map((error) {
              return error['msg']?.toString() ?? 'Unable to delete group';
            })
            .join('\n');

        throw Exception(messages);
      }

      throw Exception(responseData['message'] ?? 'Failed to delete group');
    } catch (e) {
      throw Exception('Error deleting group: $e');
    }
  }
}
