import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/assetTypeCRUDModel.dart';
import '../apiUrl.dart';

class AssetTypeApiService {
  Future<AssetTypeCRUDModel> getAssetTypes({
    String? searchText,
    int page = 1,
    int sizePerPage = 10,
    int currentIndex = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken') ?? '';

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
        BaseURLConfig.assetTypeURLService,
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : {};

      if (response.statusCode == 200) {
        return AssetTypeCRUDModel.fromJson(responseData);
      }

      throw Exception(
        responseData['message']?.toString() ?? 'Failed to fetch asset types',
      );
    } catch (e) {
      throw Exception('Error fetching asset types: $e');
    }
  }

  Future createAssetType(Map<String, dynamic> assetTypeData) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.post(
        Uri.parse(BaseURLConfig.assetTypeURLService),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(assetTypeData),
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      }

      if (responseData['errors'] is List) {
        final errors = responseData['errors'] as List;

        final messages = errors
            .map((error) => error['msg']?.toString() ?? 'Invalid field')
            .join('\n');

        throw Exception(messages);
      }

      throw Exception(responseData['message'] ?? 'Failed to create asset type');
    } catch (e) {
      throw Exception('Error creating asset type: $e');
    }
  }

  Future updateAssetType(
    String assetTypeId,
    Map<String, dynamic> assetTypeData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.put(
        Uri.parse('${BaseURLConfig.assetTypeURLService}/$assetTypeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(assetTypeData),
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return responseData;
      }

      if (responseData['errors'] is List) {
        final errors = responseData['errors'] as List;

        final messages = errors
            .map((error) => error['msg']?.toString() ?? 'Invalid field')
            .join('\n');

        throw Exception(messages);
      }

      throw Exception(responseData['message'] ?? 'Failed to update asset type');
    } catch (e) {
      throw Exception('Error updating asset type: $e');
    }
  }

  Future deleteAssetType(String assetTypeId) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    try {
      final response = await http.delete(
        Uri.parse('${BaseURLConfig.assetTypeURLService}/$assetTypeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 204) {
        return responseData;
      }

      if (responseData['errors'] is List) {
        final errors = responseData['errors'] as List;

        final messages = errors
            .map(
              (error) =>
                  error['msg']?.toString() ?? 'Unable to delete asset type',
            )
            .join('\n');

        throw Exception(messages);
      }

      throw Exception(responseData['message'] ?? 'Failed to delete asset type');
    } catch (e) {
      throw Exception('Error deleting asset type: $e');
    }
  }
}
