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
  String _getRoleName(dynamic roleId) {
    switch (roleId?.toString()) {
      case '2':
        return 'Super Admin';
      case '4':
        return 'Admin';
      case '3':
        return 'Manager';
      case '5':
        return 'Fleet Manager';
      case '6':
        return 'Route Manager';
      case '7':
        return 'Driver';
      case '9':
        return 'Viewer';
      default:
        return 'Unknown Role';
    }
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

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('accessToken', token.toString());

        await prefs.setString('user_id', userData['id']?.toString() ?? '');

        await prefs.setString(
          'fullname',
          userData['full_name']?.toString() ?? '',
        );

        await prefs.setString('email', userData['email']?.toString() ?? '');

        await prefs.setString(
          'organization_id',
          userData['organization_id']?.toString() ?? '',
        );

        await prefs.setString(
          'organization_name',
          userData['organization_name']?.toString() ?? '',
        );

        await prefs.setString('role_id', userData['role_id']?.toString() ?? '');

        final String roleName = _getRoleName(userData['role_id']);

        await prefs.setString('role', roleName);
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
