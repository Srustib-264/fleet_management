class OrgCRUDModel {
  final bool success;
  final String message;
  final List<OrgData> data;
  final Pagination? pagination;

  OrgCRUDModel({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory OrgCRUDModel.fromJson(Map<String, dynamic> json) {
    return OrgCRUDModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<OrgData>.from(
              (json['data'] as List).map((item) => OrgData.fromJson(item)),
            )
          : [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class Pagination {
  final int page;
  final int sizePerPage;
  final int currentIndex;
  final int totalRecords;
  final int totalPages;

  Pagination({
    required this.page,
    required this.sizePerPage,
    required this.currentIndex,
    required this.totalRecords,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      sizePerPage: json['sizePerPage'] ?? 10,
      currentIndex: json['currentIndex'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'sizePerPage': sizePerPage,
      'currentIndex': currentIndex,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
    };
  }
}

class OrgData {
  final String? id;
  final int? orgCode;
  final String? orgName;
  final String? description;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  OrgData({
    this.id,
    this.orgCode,
    this.orgName,
    this.description,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory OrgData.fromJson(Map<String, dynamic> json) {
    return OrgData(
      id: json['id']?.toString(),

      orgCode: json['org_code'] is int
          ? json['org_code']
          : int.tryParse(json['org_code']?.toString() ?? ''),

      orgName: json['org_name']?.toString(),

      description: json['description']?.toString(),

      contactPerson: json['contact_person']?.toString(),

      email: json['email']?.toString(),

      phone: json['phone']?.toString(),

      address: json['address']?.toString(),

      status: json['status']?.toString(),

      createdAt: json['created_at']?.toString(),

      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_code': orgCode,
      'org_name': orgName,
      'description': description,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
