class GroupCRUDModel {
  bool? success;
  String? message;
  List<GroupData>? data;

  GroupCRUDModel({this.success, this.message, this.data});

  GroupCRUDModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    if (json['data'] != null) {
      data = <GroupData>[];

      json['data'].forEach((v) {
        data!.add(GroupData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['success'] = success;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class GroupData {
  String? id;
  String? organizationId;
  int? groupCode;
  String? groupName;
  String? description;
  String? createdAt;
  String? updatedAt;

  GroupData({
    this.id,
    this.organizationId,
    this.groupCode,
    this.groupName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  GroupData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();

    organizationId = json['organization_id']?.toString();

    groupCode = json['group_code'] is int
        ? json['group_code']
        : int.tryParse(json['group_code']?.toString() ?? '');

    groupName = json['group_name']?.toString();

    description = json['description']?.toString();

    createdAt = json['created_at']?.toString();

    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['organization_id'] = organizationId;
    data['group_code'] = groupCode;
    data['group_name'] = groupName;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    return data;
  }
}
