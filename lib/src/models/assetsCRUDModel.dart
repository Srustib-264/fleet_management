class AssetsCRUDModel {
  final bool success;
  final String message;
  final List<Asset> data;
  final Pagination pagination;

  AssetsCRUDModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory AssetsCRUDModel.fromJson(Map<String, dynamic> json) {
    return AssetsCRUDModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Asset.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Asset {
  final String id;
  final String assetCode;
  final String assetName;
  final String organizationId;
  final String groupId;
  final String assetTypeId;
  final String? parentAssetId;
  final String serialNo;
  final String qrCode;
  final String barcode;
  final String? assetStatus;
  final String? ownershipType;
  final String? installationDate;
  final String? commissioningDate;
  final String? purchaseDate;
  final String? purchaseCost;
  final String? warrantyStartDate;
  final String? warrantyEndDate;
  final bool isActive;
  final String? remarks;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;

  Asset({
    required this.id,
    required this.assetCode,
    required this.assetName,
    required this.organizationId,
    required this.groupId,
    required this.assetTypeId,
    this.parentAssetId,
    required this.serialNo,
    required this.qrCode,
    required this.barcode,
    this.assetStatus,
    this.ownershipType,
    this.installationDate,
    this.commissioningDate,
    this.purchaseDate,
    this.purchaseCost,
    this.warrantyStartDate,
    this.warrantyEndDate,
    required this.isActive,
    this.remarks,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id']?.toString() ?? '',
      assetCode: json['asset_code']?.toString() ?? '',
      assetName: json['asset_name']?.toString() ?? '',
      organizationId: json['organization_id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      assetTypeId: json['asset_type_id']?.toString() ?? '',
      parentAssetId: json['parent_asset_id']?.toString(),
      serialNo: json['serial_no']?.toString() ?? '',
      qrCode: json['qr_code']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      assetStatus: json['asset_status']?.toString(),
      ownershipType: json['ownership_type']?.toString(),
      installationDate: json['installation_date']?.toString(),
      commissioningDate: json['commissioning_date']?.toString(),
      purchaseDate: json['purchase_date']?.toString(),
      purchaseCost: json['purchase_cost']?.toString(),
      warrantyStartDate: json['warranty_start_date']?.toString(),
      warrantyEndDate: json['warranty_end_date']?.toString(),
      isActive: json['is_active'] ?? false,
      remarks: json['remarks']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
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
}
