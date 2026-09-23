class AssetTypeCRUDModel {
  final bool success;
  final String message;
  final List<AssetType> data;
  final Pagination pagination;

  AssetTypeCRUDModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory AssetTypeCRUDModel.fromJson(Map<String, dynamic> json) {
    return AssetTypeCRUDModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => AssetType.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class AssetType {
  final String id;
  final String assetTypeCode;
  final String assetTypeName;
  final String category;
  final String description;
  final bool isCritical;
  final String createdAt;
  final String updatedAt;

  AssetType({
    required this.id,
    required this.assetTypeCode,
    required this.assetTypeName,
    required this.category,
    required this.description,
    required this.isCritical,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetType.fromJson(Map<String, dynamic> json) {
    return AssetType(
      id: json['id']?.toString() ?? '',
      assetTypeCode: json['asset_type_code']?.toString() ?? '',
      assetTypeName: json['asset_type_name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isCritical: json['is_critical'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_type_code': assetTypeCode,
      'asset_type_name': assetTypeName,
      'category': category,
      'description': description,
      'is_critical': isCritical,
      'created_at': createdAt,
      'updated_at': updatedAt,
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
      totalPages: json['totalPages'] ?? 0,
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
