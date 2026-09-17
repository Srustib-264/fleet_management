class RoleCRUDModel {
  bool? success;
  String? message;
  List<RoleData>? data;

  RoleCRUDModel({this.success, this.message, this.data});

  RoleCRUDModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    if (json['data'] != null) {
      data = <RoleData>[];

      json['data'].forEach((v) {
        data!.add(RoleData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['success'] = success;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

// ============================================================
// ROLE DATA
// ============================================================

class RoleData {
  String? id;
  int? roleCode;
  String? roleName;
  String? description;
  int? hierarchyLevel;
  bool? isSystemRole;
  String? createdAt;
  String? updatedAt;

  RoleData({
    this.id,
    this.roleCode,
    this.roleName,
    this.description,
    this.hierarchyLevel,
    this.isSystemRole,
    this.createdAt,
    this.updatedAt,
  });

  RoleData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();

    roleCode = json['role_code'] is int
        ? json['role_code']
        : int.tryParse(json['role_code']?.toString() ?? '');

    roleName = json['role_name']?.toString();

    description = json['description']?.toString();

    hierarchyLevel = json['hierarchy_level'] is int
        ? json['hierarchy_level']
        : int.tryParse(json['hierarchy_level']?.toString() ?? '');

    isSystemRole = json['is_system_role'];

    createdAt = json['created_at']?.toString();

    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['role_code'] = roleCode;
    data['role_name'] = roleName;
    data['description'] = description;
    data['hierarchy_level'] = hierarchyLevel;
    data['is_system_role'] = isSystemRole;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    return data;
  }
}
