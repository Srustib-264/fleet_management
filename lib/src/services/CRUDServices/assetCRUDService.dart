import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/assetsCRUDModel.dart';
import '../apiUrl.dart';

class AssetsApiService {
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken") ?? "";
  }

  Future<AssetsCRUDModel> getAssets({
    String? searchText,
    int page = 1,
    int sizePerPage = 10,
    int currentIndex = 0,
  }) async {
    final token = await _token();

    final queryParameters = <String, String>{
      'page': page.toString(),
      'sizePerPage': sizePerPage.toString(),
      'currentIndex': currentIndex.toString(),
    };

    if (searchText != null && searchText.trim().isNotEmpty) {
      queryParameters['searchText'] = searchText.trim();
    }

    final uri = Uri.parse(
      BaseURLConfig.assetsTypeURLService,
    ).replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return AssetsCRUDModel.fromJson(responseData);
    }

    throw Exception(
      'Failed to fetch assets: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Asset> getAssetById(String assetId) async {
    final token = await _token();

    final uri = Uri.parse('${BaseURLConfig.assetsTypeURLService}/$assetId');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final data = responseData['data'];

      return Asset.fromJson(data is Map<String, dynamic> ? data : responseData);
    }

    throw Exception(
      'Failed to fetch asset: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createAsset(
    Map<String, dynamic> assetData,
  ) async {
    final token = await _token();

    final uri = Uri.parse(BaseURLConfig.assetsTypeURLService);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(assetData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create asset: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> updateAsset(
    String assetId,
    Map<String, dynamic> assetData,
  ) async {
    final token = await _token();

    final uri = Uri.parse('${BaseURLConfig.assetsTypeURLService}/$assetId');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(assetData),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      if (response.body.isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update asset: '
      '${response.statusCode} ${response.body}',
    );
  }

  Future<void> deleteAsset(String assetId) async {
    final token = await _token();

    final uri = Uri.parse('${BaseURLConfig.assetsTypeURLService}/$assetId');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to delete asset: '
      '${response.statusCode} ${response.body}',
    );
  }
}
