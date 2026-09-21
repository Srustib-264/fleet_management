class UserCRUDModel {
  bool? success;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  UserCRUDModel({this.success, this.message, this.data, this.pagination});

  UserCRUDModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    // Users data
    if (json['data'] != null) {
      data = <Data>[];

      for (var item in json['data']) {
        data!.add(Data.fromJson(item));
      }
    }

    // Pagination data
    if (json['pagination'] != null) {
      pagination = Pagination.fromJson(json['pagination']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['success'] = success;
    data['message'] = message;

    // Users data
    if (this.data != null) {
      data['data'] = this.data!.map((item) => item.toJson()).toList();
    }

    // Pagination data
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }

    return data;
  }
}

// ============================================================
// PAGINATION MODEL
// ============================================================

class Pagination {
  int? page;
  int? sizePerPage;
  int? currentIndex;
  int? totalRecords;
  int? totalPages;

  Pagination({
    this.page,
    this.sizePerPage,
    this.currentIndex,
    this.totalRecords,
    this.totalPages,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    sizePerPage = json['sizePerPage'];
    currentIndex = json['currentIndex'];
    totalRecords = json['totalRecords'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['page'] = page;
    data['sizePerPage'] = sizePerPage;
    data['currentIndex'] = currentIndex;
    data['totalRecords'] = totalRecords;
    data['totalPages'] = totalPages;

    return data;
  }
}

// ============================================================
// USER DATA MODEL
// ============================================================

class Data {
  String? id;
  int? employeeCode;
  String? firstName;
  String? lastName;
  String? fullName;
  String? email;
  String? mobile;
  String? passwordHash;
  String? profilePhoto;
  String? gender;
  String? dob;
  String? organizationId;
  String? userRole;
  String? status;
  String? lastLogin;
  bool? isActive;
  dynamic createdBy;
  String? createdAt;
  String? updatedAt;

  Data({
    this.id,
    this.employeeCode,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.mobile,
    this.passwordHash,
    this.profilePhoto,
    this.gender,
    this.dob,
    this.organizationId,
    this.userRole,
    this.status,
    this.lastLogin,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeCode = json['employee_code'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    fullName = json['full_name'];
    email = json['email'];
    mobile = json['mobile'];
    passwordHash = json['password_hash'];
    profilePhoto = json['profile_photo'];
    gender = json['gender'];
    dob = json['dob'];
    organizationId = json['organization_id'];
    userRole = json['user_role'];
    status = json['status'];
    lastLogin = json['last_login'];
    isActive = json['is_active'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['employee_code'] = employeeCode;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['full_name'] = fullName;
    data['email'] = email;
    data['mobile'] = mobile;
    data['password_hash'] = passwordHash;
    data['profile_photo'] = profilePhoto;
    data['gender'] = gender;
    data['dob'] = dob;
    data['organization_id'] = organizationId;
    data['user_role'] = userRole;
    data['status'] = status;
    data['last_login'] = lastLogin;
    data['is_active'] = isActive;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    return data;
  }
}
