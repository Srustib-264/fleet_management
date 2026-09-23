import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fleet_management/src/models/groupCRUDModel.dart';
import 'package:fleet_management/src/services/CRUDServices/groupCRUDService.dart';
import 'package:flutter/material.dart';

import '../../models/assetsCRUDModel.dart';
import '../../models/orgCRUDModel.dart';
import '../../services/CRUDServices/assetCRUDService.dart';
import '../../services/CRUDServices/orgCRUDApiService.dart';
import '../forms/assetsCRUDUpdate.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final AssetsApiService _assetsApiService = AssetsApiService();

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  AssetsCRUDModel? assetsData;

  List<Asset> visibleAssets = [];
  final OrgApiService _orgApiService = OrgApiService();
  OrgCRUDModel? organizationData;
  bool isOrganizationsLoading = false;
  String? organizationError;
  OrgData? selectedOrganization;

  final Map<String, String> organizationNames = {};
  final GroupApiService _groupApiService = GroupApiService();
  GroupCRUDModel? groupData;
  bool isgroupLoading = false;
  String? groupError;

  final Map<String, String> groupNames = {};
  bool isLoading = true;
  String? errorMessage;

  int currentPage = 1;
  int rowsPerPage = 10;
  int totalPages = 1;
  int totalCount = 0;

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '-';
    }

    return date.split('T').first;
  }

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _loadOrganizations();
    _loadGroupNames();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets({String? searchText}) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _assetsApiService.getAssets(
        searchText: searchText,
        page: currentPage,
        sizePerPage: rowsPerPage,
        currentIndex: (currentPage - 1) * rowsPerPage,
      );

      if (!mounted) return;

      setState(() {
        assetsData = result;

        visibleAssets = List<Asset>.from(result.data);

        totalCount = result.pagination.totalRecords;
        totalPages = result.pagination.totalPages;

        if (totalPages < 1) {
          totalPages = 1;
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadOrganizations() async {
    if (!mounted) return;

    setState(() {
      isOrganizationsLoading = true;
      organizationError = null;
    });

    try {
      final result = await _orgApiService.getOrganizations(
        page: 1,
        sizePerPage: 1000,
        currentIndex: 0,
      );

      if (!mounted) return;

      organizationNames.clear();

      for (final organization in result.data) {
        organizationNames[organization.id.toString()] =
            organization.orgName ?? '-';
      }

      setState(() {
        organizationData = result;
        isOrganizationsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isOrganizationsLoading = false;
        organizationError = e.toString();
      });
    }
  }

  Future<void> _loadGroupNames() async {
    if (!mounted) return;

    setState(() {
      isgroupLoading = true;
      groupError = null;
    });

    try {
      final GroupCRUDModel result = await _groupApiService.getGroups(
        page: 1,
        sizePerPage: 1000,
        currentIndex: 0,
      );

      if (!mounted) return;

      groupNames.clear();

      for (final group in result.data ?? []) {
        groupNames[group.id.toString()] = group.groupName ?? '-';
      }

      setState(() {
        groupData = result;
        isgroupLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isgroupLoading = false;
        groupError = e.toString();
      });
    }
  }

  Future<void> _showAddAssetDialog() async {
    final assetCodeController = TextEditingController();
    final assetNameController = TextEditingController();
    // final organizationIdController = TextEditingController();
    final groupIdController = TextEditingController();
    final assetTypeIdController = TextEditingController();
    final parentAssetIdController = TextEditingController();
    final serialNoController = TextEditingController();
    final qrCodeController = TextEditingController();
    final barcodeController = TextEditingController();
    final statusController = TextEditingController();
    final ownershipTypeController = TextEditingController();
    final purchaseCostController = TextEditingController();
    final remarksController = TextEditingController();
    List<OrgData> organizations = organizationData?.data ?? [];
    List<GroupData> groups = groupData?.data ?? [];

    GroupData? selectedGroup;
    DateTime? installationDate;
    DateTime? commissioningDate;
    DateTime? purchaseDate;
    DateTime? warrantyStartDate;
    DateTime? warrantyEndDate;

    bool isActive = true;
    bool isCreating = false;

    String formatDate(DateTime date) {
      final month = date.month.toString().padLeft(2, '0');

      final day = date.day.toString().padLeft(2, '0');

      return '${date.year}-$month-$day';
    }

    Future<void> selectDate(
      BuildContext dialogContext,
      void Function(void Function()) setDialogState,
      String type,
    ) async {
      DateTime initialDate = DateTime.now();

      switch (type) {
        case 'installation':
          initialDate = installationDate ?? DateTime.now();
          break;

        case 'commissioning':
          initialDate = commissioningDate ?? DateTime.now();
          break;

        case 'purchase':
          initialDate = purchaseDate ?? DateTime.now();
          break;

        case 'warrantyStart':
          initialDate = warrantyStartDate ?? DateTime.now();
          break;

        case 'warrantyEnd':
          initialDate = warrantyEndDate ?? DateTime.now();
          break;
      }

      final picked = await showDatePicker(
        context: dialogContext,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked == null) return;

      setDialogState(() {
        switch (type) {
          case 'installation':
            installationDate = picked;
            break;

          case 'commissioning':
            commissioningDate = picked;
            break;

          case 'purchase':
            purchaseDate = picked;
            break;

          case 'warrantyStart':
            warrantyStartDate = picked;
            break;

          case 'warrantyEnd':
            warrantyEndDate = picked;
            break;
        }
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> createAsset() async {
              final assetCode = assetCodeController.text.trim();

              final assetName = assetNameController.text.trim();

              final organizationId = selectedOrganization?.id.toString() ?? '';
              final groupId = groupIdController.text.trim();

              final assetTypeId = assetTypeIdController.text.trim();

              final serialNo = serialNoController.text.trim();

              final qrCode = qrCodeController.text.trim();

              final barcode = barcodeController.text.trim();

              if (assetCode.isEmpty) {
                _showError('Asset Code is required');
                return;
              }

              if (assetName.isEmpty) {
                _showError('Asset Name is required');
                return;
              }

              if (organizationId.isEmpty) {
                _showError('Organization ID is required');
                return;
              }

              if (assetTypeId.isEmpty) {
                _showError('Asset Type ID is required');
                return;
              }

              if (serialNo.isEmpty) {
                _showError('Serial Number is required');
                return;
              }

              setDialogState(() {
                isCreating = true;
              });

              try {
                final body = <String, dynamic>{
                  'asset_code': assetCode,
                  'asset_name': assetName,
                  'organization_id': organizationId,
                  'group_id': groupId,
                  'asset_type_id': assetTypeId,
                  'parent_asset_id': parentAssetIdController.text.trim().isEmpty
                      ? null
                      : parentAssetIdController.text.trim(),
                  'serial_no': serialNo,
                  'qr_code': qrCode,
                  'barcode': barcode,
                  'asset_status': statusController.text.trim().isEmpty
                      ? null
                      : statusController.text.trim(),
                  'ownership_type': ownershipTypeController.text.trim().isEmpty
                      ? null
                      : ownershipTypeController.text.trim(),
                  'installation_date': installationDate == null
                      ? null
                      : formatDate(installationDate!),
                  'commissioning_date': commissioningDate == null
                      ? null
                      : formatDate(commissioningDate!),
                  'purchase_date': purchaseDate == null
                      ? null
                      : formatDate(purchaseDate!),
                  'purchase_cost': purchaseCostController.text.trim().isEmpty
                      ? null
                      : purchaseCostController.text.trim(),
                  'warranty_start_date': warrantyStartDate == null
                      ? null
                      : formatDate(warrantyStartDate!),
                  'warranty_end_date': warrantyEndDate == null
                      ? null
                      : formatDate(warrantyEndDate!),
                  'is_active': isActive,
                  'remarks': remarksController.text.trim().isEmpty
                      ? null
                      : remarksController.text.trim(),
                };

                await _assetsApiService.createAsset(body);

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadAssets(
                  searchText: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                );

                if (!mounted) return;

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Asset created successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isCreating = false;
                });

                _showError(e.toString().replaceFirst('Exception: ', ''));
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 25,
              ),
              child: Container(
                width: 760,
                constraints: const BoxConstraints(
                  maxWidth: 760,
                  maxHeight: 700,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff202b39),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xff078df5).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xff078df5),
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Asset',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Create a new asset and configure its details',
                                  style: TextStyle(
                                    color: Color(0xff8994a2),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isCreating
                                ? null
                                : () {
                                    Navigator.pop(dialogContext);
                                  },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xff8994a2),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.white.withOpacity(0.07)),

                    // FORM
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'Asset Code',
                                    controller: assetCodeController,
                                    icon: Icons.tag_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildField(
                                    label: 'Asset Name',
                                    controller: assetNameController,
                                    icon: Icons.inventory_2_outlined,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField2<OrgData>(
                                    value: selectedOrganization,
                                    isExpanded: true,

                                    decoration: InputDecoration(
                                      labelText: 'Organization',
                                      labelStyle: const TextStyle(
                                        color: Color(0xff8994a2),
                                        fontSize: 12,
                                      ),

                                      prefixIcon: const Icon(
                                        Icons.business_outlined,
                                        size: 17,
                                        color: Color(0xff8994a2),
                                      ),

                                      filled: true,
                                      fillColor: const Color(0xff141d28),

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 15,
                                          ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),

                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.06),
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xff078df5),
                                        ),
                                      ),
                                    ),

                                    hint: const Text(
                                      'Select Organization',
                                      style: TextStyle(
                                        color: Color(0xff596575),
                                        fontSize: 11,
                                      ),
                                    ),

                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 150,

                                      isOverButton: true,

                                      offset: const Offset(0, -50),

                                      padding: EdgeInsets.zero,

                                      decoration: BoxDecoration(
                                        color: const Color(0xff202b39),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),

                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(10),
                                        thickness: WidgetStateProperty.all(5),
                                        thumbVisibility:
                                            WidgetStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 42,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                    ),

                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                        color: Color(0xff8994a2),
                                      ),
                                    ),

                                    items: organizations
                                        .map<DropdownMenuItem<OrgData>>((
                                          OrgData org,
                                        ) {
                                          return DropdownMenuItem<OrgData>(
                                            value: org,
                                            child: Text(
                                              org.orgName ??
                                                  'Unnamed Organization',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),

                                    onChanged: isCreating
                                        ? null
                                        : (value) {
                                            setDialogState(() {
                                              selectedOrganization = value;
                                            });
                                          },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField2<GroupData>(
                                    value: selectedGroup,
                                    isExpanded: true,

                                    decoration: InputDecoration(
                                      labelText: 'Group',
                                      labelStyle: const TextStyle(
                                        color: Color(0xff8994a2),
                                        fontSize: 12,
                                      ),

                                      prefixIcon: const Icon(
                                        Icons.groups_outlined,
                                        size: 17,
                                        color: Color(0xff8994a2),
                                      ),

                                      filled: true,
                                      fillColor: const Color(0xff141d28),

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 15,
                                          ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),

                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.06),
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xff078df5),
                                        ),
                                      ),
                                    ),

                                    hint: const Text(
                                      'Select Group',
                                      style: TextStyle(
                                        color: Color(0xff596575),
                                        fontSize: 11,
                                      ),
                                    ),

                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 150,

                                      isOverButton: true,

                                      offset: const Offset(0, -50),

                                      padding: EdgeInsets.zero,

                                      decoration: BoxDecoration(
                                        color: const Color(0xff202b39),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),

                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(10),
                                        thickness: WidgetStateProperty.all(5),
                                        thumbVisibility:
                                            WidgetStateProperty.all(true),
                                      ),
                                    ),

                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 42,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                    ),

                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                        color: Color(0xff8994a2),
                                      ),
                                    ),

                                    items: groups
                                        .map<DropdownMenuItem<GroupData>>((
                                          GroupData group,
                                        ) {
                                          return DropdownMenuItem<GroupData>(
                                            value: group,
                                            child: Text(
                                              group.groupName ??
                                                  'Unnamed Group',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),

                                    onChanged: isCreating
                                        ? null
                                        : (value) {
                                            setDialogState(() {
                                              selectedGroup = value;

                                              // Store ID for API
                                              groupIdController.text =
                                                  value?.id.toString() ?? '';
                                            });
                                          },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'Asset Type ID',
                                    controller: assetTypeIdController,
                                    icon: Icons.category_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildField(
                                    label: 'Parent Asset ID',
                                    controller: parentAssetIdController,
                                    icon: Icons.account_tree_outlined,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'Serial Number',
                                    controller: serialNoController,
                                    icon: Icons.confirmation_number_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildField(
                                    label: 'QR Code',
                                    controller: qrCodeController,
                                    icon: Icons.qr_code_2_outlined,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'Barcode',
                                    controller: barcodeController,
                                    icon: Icons.view_week_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildField(
                                    label: 'Asset Status',
                                    controller: statusController,
                                    icon: Icons.info_outline,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'Ownership Type',
                                    controller: ownershipTypeController,
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildField(
                                    label: 'Purchase Cost',
                                    controller: purchaseCostController,
                                    icon: Icons.currency_rupee,
                                  ),
                                ),
                              ],
                            ),

                            // DATE ROW 1
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateRow(
                                    label: 'Installation Date',
                                    value: installationDate,
                                    onTap: () => selectDate(
                                      dialogContext,
                                      setDialogState,
                                      'installation',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateRow(
                                    label: 'Commissioning Date',
                                    value: commissioningDate,
                                    onTap: () => selectDate(
                                      dialogContext,
                                      setDialogState,
                                      'commissioning',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // DATE ROW 2
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateRow(
                                    label: 'Purchase Date',
                                    value: purchaseDate,
                                    onTap: () => selectDate(
                                      dialogContext,
                                      setDialogState,
                                      'purchase',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateRow(
                                    label: 'Warranty Start Date',
                                    value: warrantyStartDate,
                                    onTap: () => selectDate(
                                      dialogContext,
                                      setDialogState,
                                      'warrantyStart',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // DATE ROW 3
                            _buildDateRow(
                              label: 'Warranty End Date',
                              value: warrantyEndDate,
                              onTap: () => selectDate(
                                dialogContext,
                                setDialogState,
                                'warrantyEnd',
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              label: 'Remarks',
                              controller: remarksController,
                              icon: Icons.notes_outlined,
                            ),

                            Container(
                              height: 52,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff141d28),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: Color(0xff8994a2),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Is Active',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Enable this asset',
                                          style: TextStyle(
                                            color: Color(0xff697482),
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isActive,
                                    onChanged: isCreating
                                        ? null
                                        : (value) {
                                            setDialogState(() {
                                              isActive = value;
                                            });
                                          },
                                    activeColor: Colors.white,
                                    activeTrackColor: const Color(0xff078df5),
                                    inactiveThumbColor: const Color(0xff8994a2),
                                    inactiveTrackColor: const Color(0xff2b3745),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // FOOTER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isCreating
                                ? null
                                : () {
                                    Navigator.pop(dialogContext);
                                  },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xff8994a2),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: isCreating ? null : createAsset,
                            icon: isCreating
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add, size: 16),
                            label: Text(
                              isCreating ? 'Creating...' : 'Create Asset',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff078df5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    assetCodeController.dispose();
    assetNameController.dispose();
    // organizationIdController.dispose();
    groupIdController.dispose();
    assetTypeIdController.dispose();
    parentAssetIdController.dispose();
    serialNoController.dispose();
    qrCodeController.dispose();
    barcodeController.dispose();
    statusController.dispose();
    ownershipTypeController.dispose();
    purchaseCostController.dispose();
    remarksController.dispose();
  }

  void _showDeleteDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff202b39),

          title: const Text(
            'Delete Asset',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          content: Text(
            'Are you sure you want to delete '
            '${asset.assetName}?',
            style: const TextStyle(color: Color(0xff8994a2), fontSize: 11),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xff8994a2)),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _assetsApiService.deleteAsset(asset.id);

                  if (!mounted) return;

                  await _loadAssets(
                    searchText: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Asset deleted successfully')),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete asset: '
                        '${e.toString().replaceFirst('Exception: ', '')}',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffdc2626),
                elevation: 0,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Manage assets and their configuration',
                    style: TextStyle(color: Color(0xff8994a2), fontSize: 10),
                  ),

                  const SizedBox(height: 14),

                  // SEARCH
                  Row(
                    children: [
                      SizedBox(
                        width: 260,
                        height: 36,
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                          onChanged: (value) {
                            _searchDebounce?.cancel();

                            _searchDebounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                setState(() {
                                  currentPage = 1;
                                });

                                _loadAssets(
                                  searchText: value.trim().isEmpty
                                      ? null
                                      : value.trim(),
                                );
                              },
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search assets...',
                            hintStyle: const TextStyle(
                              color: Color(0xff596575),
                              fontSize: 11,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 17,
                              color: Color(0xff8994a2),
                            ),
                            filled: true,
                            fillColor: const Color(0xff202b39),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(7),
                              ),
                              borderSide: BorderSide(color: Color(0xff078df5)),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        'Page :',
                        style: TextStyle(
                          color: Color(0xff8994a2),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 10),

                      _buildRowsDropdown(),

                      const SizedBox(width: 10),

                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: _showAddAssetDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Add Asset',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff078df5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Expanded(child: _buildBody()),

        const SizedBox(height: 10),

        _buildPaginationControls(),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff078df5)),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xff8994a2), size: 30),

            const SizedBox(height: 12),

            const Text(
              'Unable to load assets',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _loadAssets,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (visibleAssets.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAssetsTable();
  }

  // ============================================================
  // ASSETS TABLE
  // ============================================================

  Widget _buildAssetsTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.015),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTableTheme(
                data: const DataTableThemeData(dividerThickness: 0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(
                      thickness: 0,
                      space: 0,
                      color: Colors.transparent,
                    ),
                  ),
                  child: DataTable(
                    headingRowHeight: 46,
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 60,
                    columnSpacing: 28,
                    horizontalMargin: 16,
                    dividerThickness: 0,
                    showBottomBorder: false,

                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xff202b39),
                    ),

                    headingTextStyle: const TextStyle(
                      color: Color(0xff697482),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),

                    dataTextStyle: const TextStyle(
                      color: Color(0xff8994a2),
                      fontSize: 10,
                    ),

                    border: const TableBorder(
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                      horizontalInside: BorderSide.none,
                      verticalInside: BorderSide.none,
                    ),

                    columns: const [
                      // DataColumn(label: Text('ID')),
                      DataColumn(label: Text('ASSET CODE')),
                      DataColumn(label: Text('ASSET NAME')),
                      DataColumn(label: Text('ORGANIZATION NAME')),
                      DataColumn(label: Text('GROUP NAME')),
                      DataColumn(label: Text('ASSET TYPE ID')),
                      DataColumn(label: Text('PARENT ASSET ID')),
                      DataColumn(label: Text('SERIAL NO')),
                      DataColumn(label: Text('QR CODE')),
                      DataColumn(label: Text('BARCODE')),
                      DataColumn(label: Text('ASSET STATUS')),
                      DataColumn(label: Text('OWNERSHIP TYPE')),
                      DataColumn(label: Text('INSTALLATION DATE')),
                      DataColumn(label: Text('COMMISSIONING DATE')),
                      DataColumn(label: Text('PURCHASE DATE')),
                      DataColumn(label: Text('PURCHASE COST')),
                      DataColumn(label: Text('WARRANTY START')),
                      DataColumn(label: Text('WARRANTY END')),
                      DataColumn(label: Text('ACTIVE')),
                      DataColumn(label: Text('CREATED AT')),
                      DataColumn(label: Text('UPDATED AT')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: visibleAssets.map((asset) {
                      return DataRow(
                        cells: [
                          // ID
                          // DataCell(
                          //   SizedBox(
                          //     width: 70,
                          //     child: Text(
                          //       asset.id,
                          //       overflow: TextOverflow.ellipsis,
                          //       style: const TextStyle(
                          //         color: Color(0xff8994a2),
                          //         fontSize: 10,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // ASSET CODE
                          DataCell(
                            SizedBox(
                              width: 160,
                              child: Text(
                                asset.assetCode,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          // ASSET NAME
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(
                                asset.assetName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          // ORGANIZATION ID
                          DataCell(
                            SizedBox(
                              width: 160,
                              child: Text(
                                organizationNames[asset.organizationId] ??
                                    asset.organizationId,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // GROUP ID
                          DataCell(
                            SizedBox(
                              width: 160,
                              child: Text(
                                groupNames[asset.groupId] ?? asset.groupId,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // ASSET TYPE ID
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Text(
                                asset.assetTypeId,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // PARENT ASSET ID
                          DataCell(
                            SizedBox(
                              width: 140,
                              child: Text(
                                asset.parentAssetId ?? '-',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // SERIAL NO
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                asset.serialNo,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // QR CODE
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                asset.qrCode,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // BARCODE
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                asset.barcode,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // ASSET STATUS
                          DataCell(_buildStatus(asset.assetStatus)),

                          // OWNERSHIP TYPE
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                asset.ownershipType ?? '-',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // INSTALLATION DATE
                          DataCell(
                            SizedBox(
                              width: 160,
                              child: Text(
                                formatDate(asset.installationDate ?? "-"),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // COMMISSIONING DATE
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                formatDate(asset.commissioningDate ?? "-"),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // PURCHASE DATE
                          DataCell(
                            SizedBox(
                              width: 140,
                              child: Text(
                                formatDate(asset.purchaseDate ?? "-"),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // PURCHASE COST
                          DataCell(
                            SizedBox(
                              width: 130,
                              child: Text(
                                asset.purchaseCost ?? '-',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // WARRANTY START DATE
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                formatDate(asset.warrantyStartDate ?? "-"),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // WARRANTY END DATE
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                formatDate(asset.warrantyEndDate ?? "-"),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // ACTIVE
                          DataCell(_buildActiveStatus(asset.isActive)),

                          // CREATED AT
                          DataCell(
                            SizedBox(
                              width: 210,
                              child: Text(
                                formatDate(asset.createdAt),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              width: 210,
                              child: Text(
                                formatDate(asset.updatedAt),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // ACTIONS
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  icon: Icons.edit_outlined,
                                  tooltip: 'Edit',
                                  onPressed: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AssetsCRUDUpdate(asset: asset);
                                      },
                                    );

                                    if (result == true) {
                                      await _loadAssets(
                                        searchText:
                                            _searchController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : _searchController.text.trim(),
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(width: 20),

                                _buildActionButton(
                                  icon: Icons.delete_outline,
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    _showDeleteDialog(asset);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowsDropdown() {
    return SizedBox(
      width: 70,
      height: 36,
      child: DropdownButton2<int>(
        value: rowsPerPage,
        isExpanded: true,

        buttonStyleData: ButtonStyleData(
          width: 70,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xff202b39),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
        ),

        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 17,
            color: Color(0xff8994a2),
          ),
        ),

        style: const TextStyle(color: Color(0xff8994a2), fontSize: 11),

        underline: const SizedBox(),

        dropdownStyleData: DropdownStyleData(
          width: 70,
          offset: const Offset(0, -3),
          maxHeight: 180,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: const Color(0xff202b39),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),

        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),

        items: const [
          DropdownMenuItem<int>(value: 10, child: Text('10')),
          DropdownMenuItem<int>(value: 25, child: Text('25')),
          DropdownMenuItem<int>(value: 50, child: Text('50')),
          DropdownMenuItem<int>(value: 100, child: Text('100')),
        ],

        onChanged: (value) async {
          if (value == null) return;

          setState(() {
            rowsPerPage = value;
            currentPage = 1;
          });

          await _loadAssets(
            searchText: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls() {
    const int visiblePages = 5;

    int startPage = ((currentPage - 1) ~/ visiblePages) * visiblePages + 1;

    int endPage = startPage + visiblePages - 1;

    if (endPage > totalPages) {
      endPage = totalPages;
    }

    return SizedBox(
      height: 48,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaginationArrow(
              icon: Icons.chevron_left_rounded,
              enabled: currentPage > 1,
              onTap: () async {
                setState(() {
                  currentPage--;
                });

                await _loadAssets(
                  searchText: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                );
              },
            ),

            const SizedBox(width: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(endPage - startPage + 1, (index) {
                final page = startPage + index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildPageButton(
                    page: page,
                    isSelected: page == currentPage,
                  ),
                );
              }),
            ),

            const SizedBox(width: 6),

            _buildPaginationArrow(
              icon: Icons.chevron_right_rounded,
              enabled: currentPage < totalPages,
              onTap: () async {
                setState(() {
                  currentPage++;
                });

                await _loadAssets(
                  searchText: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                );
              },
            ),

            const SizedBox(width: 20),

            Text(
              'Page $currentPage of '
              '$totalPages · '
              '$totalCount items',
              style: const TextStyle(color: Color(0xff8994a2), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton({required int page, required bool isSelected}) {
    return InkWell(
      onTap: isSelected
          ? null
          : () async {
              setState(() {
                currentPage = page;
              });

              await _loadAssets(
                searchText: _searchController.text.trim().isEmpty
                    ? null
                    : _searchController.text.trim(),
              );
            },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff078df5) : const Color(0xff202b39),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xff078df5)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xff8994a2),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 32,
        height: 38,
        child: Icon(
          icon,
          size: 23,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.20),
        ),
      ),
    );
  }

  Widget _buildStatus(String? status) {
    final value = status == null || status.trim().isEmpty
        ? 'N/A'
        : status.trim();

    final bool isActive = value.toUpperCase() == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xff078df5).withOpacity(0.10)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: isActive ? const Color(0xff078df5) : const Color(0xff8994a2),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActiveStatus(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xff078df5).withOpacity(0.10)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active ? const Color(0xff078df5) : const Color(0xff8994a2),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    String dateText = 'Select date';

    if (value != null) {
      final month = value.month.toString().padLeft(2, '0');
      final day = value.day.toString().padLeft(2, '0');

      dateText = '${value.year}-$month-$day';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        isFocused: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 12),
          floatingLabelStyle: const TextStyle(
            color: Color(0xff078df5),
            fontSize: 12,
          ),
          filled: true,
          fillColor: const Color(0xff141d28),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),

          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: 17,
            color: Color(0xff8994a2),
          ),

          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),

        child: Text(
          dateText,
          style: TextStyle(
            color: value == null ? const Color(0xff8994a2) : Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 12.5),
        cursorColor: const Color(0xff078df5),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 12),
          floatingLabelStyle: const TextStyle(
            color: Color(0xff078df5),
            fontSize: 12,
          ),
          prefixIcon: Icon(icon, size: 17, color: const Color(0xff8994a2)),
          filled: true,
          fillColor: const Color(0xff141d28),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff078df5)),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.025),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Icon(
            icon,
            size: 15,
            color: icon == Icons.delete_outline
                ? Colors.red
                : const Color(0xff078df5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 38,
            color: Colors.white.withOpacity(0.20),
          ),

          const SizedBox(height: 12),

          const Text(
            'No assets found',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),

          const SizedBox(height: 6),

          const Text(
            'There are no assets available.',
            style: TextStyle(color: Color(0xff697482), fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
