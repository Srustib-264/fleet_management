import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/orgCRUDModel.dart';
import '../apiUrl.dart';

class OrgApiService {
  Future<OrgCRUDModel> getOrganizations({
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
        BaseURLConfig.orgCRUDApiService,
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
        return OrgCRUDModel.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to fetch organizations',
        );
      }
    } catch (e) {
      throw Exception('Error fetching organizations: $e');
    }
  }

  Future<void> addOrganization(Map<String, dynamic> organizationData) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.post(
        Uri.parse(BaseURLConfig.orgCRUDApiService),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(organizationData),
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to add organization',
        );
      }
    } catch (e) {
      throw Exception('Error adding organization: $e');
    }
  }

  Future<void> updateOrganization(
    String organizationId,
    Map<String, dynamic> organizationData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.put(
        Uri.parse('${BaseURLConfig.orgCRUDApiService}/$organizationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(organizationData),
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to update organization',
        );
      }
    } catch (e) {
      throw Exception('Error updating organization: $e');
    }
  }

  Future<void> deleteOrganization(String organizationId) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.delete(
        Uri.parse('${BaseURLConfig.orgCRUDApiService}/$organizationId'),
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
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to delete organization',
        );
      }
    } catch (e) {
      throw Exception('Error deleting organization: $e');
    }
  }
}
