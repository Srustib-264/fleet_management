import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../models/assetsCRUDModel.dart';
import '../../models/groupCRUDModel.dart';
import '../../models/orgCRUDModel.dart';
import '../../services/CRUDServices/assetCRUDService.dart';
import '../../services/CRUDServices/groupCRUDService.dart';
import '../../services/CRUDServices/orgCRUDApiService.dart';

class AssetsCRUDUpdate extends StatefulWidget {
  final Asset asset;

  const AssetsCRUDUpdate({super.key, required this.asset});

  @override
  State<AssetsCRUDUpdate> createState() => _AssetsCRUDUpdateState();
}

class _AssetsCRUDUpdateState extends State<AssetsCRUDUpdate> {
  final AssetsApiService _assetsApiService = AssetsApiService();
  final OrgApiService _orgApiService = OrgApiService();
  final GroupApiService _groupApiService = GroupApiService();

  late TextEditingController _assetCodeController;
  late TextEditingController _assetNameController;
  late TextEditingController _organizationIdController;
  late TextEditingController _groupIdController;
  late TextEditingController _assetTypeIdController;
  late TextEditingController _parentAssetIdController;
  late TextEditingController _serialNoController;
  late TextEditingController _qrCodeController;
  late TextEditingController _barcodeController;
  late TextEditingController _assetStatusController;
  late TextEditingController _ownershipTypeController;
  late TextEditingController _installationDateController;
  late TextEditingController _commissioningDateController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _purchaseCostController;
  late TextEditingController _warrantyStartDateController;
  late TextEditingController _warrantyEndDateController;

  // Organization / Group
  List<OrgData> _organizations = [];
  List<GroupData> _groups = [];

  OrgData? _selectedOrganization;
  GroupData? _selectedGroup;

  bool _isOrganizationsLoading = false;
  bool _isGroupsLoading = false;

  bool _isActive = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    final asset = widget.asset;

    _assetCodeController = TextEditingController(text: asset.assetCode);

    _assetNameController = TextEditingController(text: asset.assetName);

    _organizationIdController = TextEditingController(
      text: asset.organizationId,
    );

    _groupIdController = TextEditingController(text: asset.groupId);

    _assetTypeIdController = TextEditingController(text: asset.assetTypeId);

    _parentAssetIdController = TextEditingController(
      text: asset.parentAssetId ?? '',
    );

    _serialNoController = TextEditingController(text: asset.serialNo);

    _qrCodeController = TextEditingController(text: asset.qrCode);

    _barcodeController = TextEditingController(text: asset.barcode);

    _assetStatusController = TextEditingController(
      text: asset.assetStatus ?? '',
    );

    _ownershipTypeController = TextEditingController(
      text: asset.ownershipType ?? '',
    );

    _installationDateController = TextEditingController(
      text: _formatExistingDate(asset.installationDate),
    );

    _commissioningDateController = TextEditingController(
      text: _formatExistingDate(asset.commissioningDate),
    );

    _purchaseDateController = TextEditingController(
      text: _formatExistingDate(asset.purchaseDate),
    );

    _purchaseCostController = TextEditingController(
      text: asset.purchaseCost ?? '',
    );

    _warrantyStartDateController = TextEditingController(
      text: _formatExistingDate(asset.warrantyStartDate),
    );

    _warrantyEndDateController = TextEditingController(
      text: _formatExistingDate(asset.warrantyEndDate),
    );

    _isActive = asset.isActive;

    _loadOrganizations();
    _loadGroups();
  }

  String _formatExistingDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return '';
    }

    try {
      final parsed = DateTime.parse(date);

      final month = parsed.month.toString().padLeft(2, '0');
      final day = parsed.day.toString().padLeft(2, '0');

      return '${parsed.year}-$month-$day';
    } catch (_) {
      return date.split('T').first;
    }
  }

  Future<void> _loadOrganizations() async {
    if (!mounted) return;

    setState(() {
      _isOrganizationsLoading = true;
    });

    try {
      final result = await _orgApiService.getOrganizations(
        page: 1,
        sizePerPage: 1000,
        currentIndex: 0,
      );

      if (!mounted) return;

      final organizations = result.data;

      OrgData? selected;

      for (final organization in organizations) {
        if (organization.id.toString() ==
            widget.asset.organizationId.toString()) {
          selected = organization;
          break;
        }
      }

      setState(() {
        _organizations = organizations;
        _selectedOrganization = selected;
        _isOrganizationsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isOrganizationsLoading = false;
      });

      _showError(
        'Failed to load organizations: '
        '${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> _loadGroups() async {
    if (!mounted) return;

    setState(() {
      _isGroupsLoading = true;
    });

    try {
      final result = await _groupApiService.getGroups(
        page: 1,
        sizePerPage: 1000,
        currentIndex: 0,
      );

      if (!mounted) return;

      final groups = result.data ?? [];

      GroupData? selected;

      for (final group in groups) {
        if (group.id.toString() == widget.asset.groupId.toString()) {
          selected = group;
          break;
        }
      }

      setState(() {
        _groups = groups;
        _selectedGroup = selected;
        _isGroupsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGroupsLoading = false;
      });

      _showError(
        'Failed to load groups: '
        '${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.trim().isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text.trim());
      } catch (_) {
        initialDate = DateTime.now();
      }
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final month = pickedDate.month.toString().padLeft(2, '0');
    final day = pickedDate.day.toString().padLeft(2, '0');

    setState(() {
      controller.text = '${pickedDate.year}-$month-$day';
    });
  }

  Future<void> _updateAsset() async {
    final organizationId =
        _selectedOrganization?.id.toString() ??
        _organizationIdController.text.trim();

    final groupId =
        _selectedGroup?.id.toString() ?? _groupIdController.text.trim();

    if (_assetCodeController.text.trim().isEmpty) {
      _showError('Asset Code is required');
      return;
    }

    if (_assetNameController.text.trim().isEmpty) {
      _showError('Asset Name is required');
      return;
    }

    if (organizationId.isEmpty) {
      _showError('Organization is required');
      return;
    }

    if (groupId.isEmpty) {
      _showError('Group is required');
      return;
    }

    if (_assetTypeIdController.text.trim().isEmpty) {
      _showError('Asset Type ID is required');
      return;
    }

    if (_serialNoController.text.trim().isEmpty) {
      _showError('Serial Number is required');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final body = <String, dynamic>{
        'asset_code': _assetCodeController.text.trim(),

        'asset_name': _assetNameController.text.trim(),

        'organization_id': organizationId,

        'group_id': groupId,

        'asset_type_id': _assetTypeIdController.text.trim(),

        'parent_asset_id': _parentAssetIdController.text.trim().isEmpty
            ? null
            : _parentAssetIdController.text.trim(),

        'serial_no': _serialNoController.text.trim(),

        'qr_code': _qrCodeController.text.trim(),

        'barcode': _barcodeController.text.trim(),

        'asset_status': _assetStatusController.text.trim().isEmpty
            ? null
            : _assetStatusController.text.trim(),

        'ownership_type': _ownershipTypeController.text.trim().isEmpty
            ? null
            : _ownershipTypeController.text.trim(),

        'installation_date': _installationDateController.text.trim().isEmpty
            ? null
            : _installationDateController.text.trim(),

        'commissioning_date': _commissioningDateController.text.trim().isEmpty
            ? null
            : _commissioningDateController.text.trim(),

        'purchase_date': _purchaseDateController.text.trim().isEmpty
            ? null
            : _purchaseDateController.text.trim(),

        'purchase_cost': _purchaseCostController.text.trim().isEmpty
            ? null
            : _purchaseCostController.text.trim(),

        'warranty_start_date': _warrantyStartDateController.text.trim().isEmpty
            ? null
            : _warrantyStartDateController.text.trim(),

        'warranty_end_date': _warrantyEndDateController.text.trim().isEmpty
            ? null
            : _warrantyEndDateController.text.trim(),

        'is_active': _isActive,
      };

      await _assetsApiService.updateAsset(widget.asset.id, body);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      child: Container(
        width: 820,
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
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
            _buildHeader(),

            Divider(height: 1, color: Colors.white.withOpacity(0.07)),

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
                            controller: _assetCodeController,
                            icon: Icons.tag_outlined,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'Asset Name',
                            controller: _assetNameController,
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildOrganizationDropdown()),

                        const SizedBox(width: 16),

                        Expanded(child: _buildGroupDropdown()),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Asset Type ID',
                            controller: _assetTypeIdController,
                            icon: Icons.category_outlined,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'Parent Asset ID',
                            controller: _parentAssetIdController,
                            icon: Icons.account_tree_outlined,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Serial No',
                            controller: _serialNoController,
                            icon: Icons.confirmation_number_outlined,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'QR Code',
                            controller: _qrCodeController,
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
                            controller: _barcodeController,
                            icon: Icons.view_week_outlined,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'Asset Status',
                            controller: _assetStatusController,
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
                            controller: _ownershipTypeController,
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'Purchase Cost',
                            controller: _purchaseCostController,
                            icon: Icons.currency_rupee,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Installation Date',
                            controller: _installationDateController,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildDateField(
                            label: 'Commissioning Date',
                            controller: _commissioningDateController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Purchase Date',
                            controller: _purchaseDateController,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildDateField(
                            label: 'Warranty Start Date',
                            controller: _warrantyStartDateController,
                          ),
                        ),
                      ],
                    ),

                    _buildDateField(
                      label: 'Warranty End Date',
                      controller: _warrantyEndDateController,
                    ),

                    _buildActiveSwitch(),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: Colors.white.withOpacity(0.07)),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField2<OrgData>(
        value: _selectedOrganization,
        isExpanded: true,

        decoration: InputDecoration(
          labelText: 'Organization',

          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 12),

          floatingLabelStyle: const TextStyle(
            color: Color(0xff078df5),
            fontSize: 12,
          ),

          prefixIcon: const Icon(
            Icons.business_outlined,
            size: 17,
            color: Color(0xff8994a2),
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

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff078df5)),
          ),
        ),

        hint: const Text(
          'Select Organization',
          style: TextStyle(color: Color(0xff596575), fontSize: 11),
        ),

        dropdownStyleData: DropdownStyleData(
          maxHeight: 150,
          isOverButton: true,
          offset: const Offset(0, -50),
          padding: EdgeInsets.zero,

          decoration: BoxDecoration(
            color: const Color(0xff202b39),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(10),
            thickness: WidgetStateProperty.all(5),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),

        menuItemStyleData: const MenuItemStyleData(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: 14),
        ),

        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xff8994a2),
          ),
        ),

        items: _organizations.map<DropdownMenuItem<OrgData>>((
          OrgData organization,
        ) {
          return DropdownMenuItem<OrgData>(
            value: organization,
            child: Text(
              organization.orgName ?? 'Unnamed Organization',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }).toList(),

        onChanged: _isUpdating || _isOrganizationsLoading
            ? null
            : (value) {
                setState(() {
                  _selectedOrganization = value;

                  _organizationIdController.text = value?.id.toString() ?? '';
                });
              },
      ),
    );
  }

  Widget _buildGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField2<GroupData>(
        value: _selectedGroup,
        isExpanded: true,

        decoration: InputDecoration(
          labelText: 'Group',

          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 12),

          floatingLabelStyle: const TextStyle(
            color: Color(0xff078df5),
            fontSize: 12,
          ),

          prefixIcon: const Icon(
            Icons.groups_outlined,
            size: 17,
            color: Color(0xff8994a2),
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

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff078df5)),
          ),
        ),

        hint: const Text(
          'Select Group',
          style: TextStyle(color: Color(0xff596575), fontSize: 11),
        ),

        dropdownStyleData: DropdownStyleData(
          maxHeight: 150,
          isOverButton: true,
          offset: const Offset(0, -50),
          padding: EdgeInsets.zero,

          decoration: BoxDecoration(
            color: const Color(0xff202b39),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(10),
            thickness: WidgetStateProperty.all(5),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),

        menuItemStyleData: const MenuItemStyleData(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: 14),
        ),

        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xff8994a2),
          ),
        ),

        items: _groups.map<DropdownMenuItem<GroupData>>((GroupData group) {
          return DropdownMenuItem<GroupData>(
            value: group,
            child: Text(
              group.groupName ?? 'Unnamed Group',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }).toList(),

        onChanged: _isUpdating || _isGroupsLoading
            ? null
            : (value) {
                setState(() {
                  _selectedGroup = value;

                  _groupIdController.text = value?.id.toString() ?? '';
                });
              },
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        enabled: !_isUpdating,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        cursorColor: const Color(0xff078df5),

        onTap: () => _selectDate(controller),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 12),

          floatingLabelStyle: const TextStyle(
            color: Color(0xff078df5),
            fontSize: 12,
          ),

          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: 17,
            color: Color(0xff8994a2),
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

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff078df5)),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              Icons.edit_outlined,
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
                  'Edit Asset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Update asset details',
                  style: TextStyle(color: Color(0xff8994a2), fontSize: 11),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _isUpdating
                ? null
                : () {
                    Navigator.pop(context);
                  },
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
              color: Color(0xff8994a2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xff141d28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Enable or disable this asset',
                  style: TextStyle(color: Color(0xff697482), fontSize: 9),
                ),
              ],
            ),
          ),

          Switch(
            value: _isActive,
            onChanged: _isUpdating
                ? null
                : (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xff078df5),
            inactiveThumbColor: const Color(0xff8994a2),
            inactiveTrackColor: const Color(0xff2b3745),
          ),
        ],
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
        enabled: !_isUpdating,
        style: const TextStyle(color: Colors.white, fontSize: 12),
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

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isUpdating
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xff8994a2), fontSize: 12),
            ),
          ),

          const SizedBox(width: 10),

          ElevatedButton.icon(
            onPressed: _isUpdating ? null : _updateAsset,

            icon: _isUpdating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 16),

            label: Text(_isUpdating ? 'Updating...' : 'Update Asset'),

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff078df5),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
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
