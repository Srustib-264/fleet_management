class OrgCRUDModel {
  final bool success;
  final String message;
  final List<OrgData> data;

  OrgCRUDModel({
    required this.success,
    required this.message,
    required this.data,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
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
