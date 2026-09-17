import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/apiUrl.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final response = await http.post(
        Uri.parse(BaseURLConfig.loginApiURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': event.email, 'password': event.password}),
      );

      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');
      debugPrint('RESPONSE HEADERS: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final token = responseData['accessToken'] ?? responseData['token'];

        if (token == null || token.toString().isEmpty) {
          emit(
            LoginFailure(
              error: 'Invalid response: missing token',
              statusCode: response.statusCode,
            ),
          );
          return;
        }

        // Get user data
        final userData = responseData['data'];

        if (userData == null) {
          emit(
            LoginFailure(
              error: 'Invalid response: missing user data',
              statusCode: response.statusCode,
            ),
          );
          return;
        }

        // Save login information
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('accessToken', token.toString());

        await prefs.setString('user_id', userData['id'].toString());

        await prefs.setString('full_name', userData['full_name'].toString());

        await prefs.setString('email', userData['email'].toString());

        await prefs.setString(
          'organization_id',
          userData['organization_id'].toString(),
        );

        await prefs.setString('role_id', userData['role_id'].toString());

        debugPrint('======================================');
        debugPrint('LOGIN DATA SAVED');
        debugPrint('User ID: ${userData['id']}');
        debugPrint('Name: ${userData['full_name']}');
        debugPrint('Organization ID: ${userData['organization_id']}');
        debugPrint('Role ID: ${userData['role_id']}');
        debugPrint('======================================');

        emit(LoginSuccess(token: token.toString()));
      } else {
        String errorMessage = 'Login failed';

        try {
          final errorData = jsonDecode(response.body);

          if (errorData is Map<String, dynamic>) {
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'Login failed';
          }
        } catch (_) {
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'Login failed';
        }

        emit(
          LoginFailure(
            error: errorMessage.toString(),
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString(), statusCode: null));
    }
  }
}
