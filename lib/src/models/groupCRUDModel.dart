class GroupCRUDModel {
  bool? success;
  String? message;
  List<GroupData>? data;
  Pagination? pagination;

  GroupCRUDModel({this.success, this.message, this.data, this.pagination});

  GroupCRUDModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    if (json['data'] != null) {
      data = <GroupData>[];

      json['data'].forEach((v) {
        data!.add(GroupData.fromJson(v));
      });
    }

    if (json['pagination'] != null) {
      pagination = Pagination.fromJson(json['pagination']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['success'] = success;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }

    return data;
  }
}

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
    return {
      'page': page,
      'sizePerPage': sizePerPage,
      'currentIndex': currentIndex,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
    };
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
