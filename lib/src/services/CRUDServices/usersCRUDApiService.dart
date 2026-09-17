import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/usersCRUDModel.dart';
import '../apiURL.dart';

class UserApiService {
  Future<UserCRUDModel> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse(BaseURLConfig.userCRUDApiService),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200) {
        return UserCRUDModel.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // ============================================================
  // DELETE USER
  // ============================================================

  Future<void> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    try {
      final response = await http.delete(
        Uri.parse('${BaseURLConfig.userCRUDApiService}/$userId'),
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
        throw Exception(responseData['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  Future<void> updateUser(
    String userId,
    Map<String, dynamic> userData, {
    XFile? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${BaseURLConfig.userCRUDApiService}/$userId'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      userData.forEach((key, value) {
        if (key != 'profile_photo' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_photo',
            bytes,
            filename: profileImage.name,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      }
      throw Exception(responseData['message'] ?? 'Failed to update user');
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> createUser(
    Map<String, dynamic> userData,
    XFile? profilePhoto,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    try {
      final uri = Uri.parse(BaseURLConfig.userCRUDApiService);

      final request = http.MultipartRequest('POST', uri);

      // Authorization
      request.headers['Authorization'] = 'Bearer $token';

      userData.forEach((key, value) {
        if (key != 'profile_photo' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add profile image
      if (profilePhoto != null) {
        final bytes = await profilePhoto.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_photo',
            bytes,
            filename: profilePhoto.name,
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception(responseData['message'] ?? 'Failed to create user');
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }
}
