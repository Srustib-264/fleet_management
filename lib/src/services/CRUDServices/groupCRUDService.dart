import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/groupCRUDModel.dart';
import '../apiUrl.dart';

class GroupApiService {
  // ============================================================
  // GET ALL GROUPS
  // ============================================================

  Future<GroupCRUDModel> getGroups({
    String? searchText,
    int page = 1,
    int sizePerPage = 10,
    int currentIndex = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'sizePerPage': sizePerPage.toString(),
        'currentIndex': currentIndex.toString(),
      };

      if (searchText != null && searchText.trim().isNotEmpty) {
        queryParams['searchText'] = searchText.trim();
      }

      final uri = Uri.parse(
        BaseURLConfig.groupCRUDApiService,
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

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

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

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

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      }

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

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

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
