class BaseURLConfig {
  static const String baseURL = "http://192.168.1.53:5000";

  // login
  static const String loginApiURL = '$baseURL/api/v1/users/login';
  static const String userCRUDApiService = '$baseURL/api/v1/users';

  static const String groupCRUDApiService = '$baseURL/api/v1/groups';
  static const String orgCRUDApiService = '$baseURL/api/v1/organizations';
  static const String rolesApiURL = '$baseURL/api/v1/roles';
}
