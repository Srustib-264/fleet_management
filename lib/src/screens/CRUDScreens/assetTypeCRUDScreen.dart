import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fleet_management/src/screens/forms/assetTypeCRUDUpdate.dart';
import 'package:flutter/material.dart';

import '../../models/assetTypeCRUDModel.dart';
import '../../services/CRUDServices/assetTypeCRUDService.dart';

class AssetTypeScreen extends StatefulWidget {
  const AssetTypeScreen({super.key});

  @override
  State<AssetTypeScreen> createState() => _AssetTypeScreenState();
}

class _AssetTypeScreenState extends State<AssetTypeScreen> {
  final AssetTypeApiService _assetTypeApiService = AssetTypeApiService();

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  AssetTypeCRUDModel? assetTypeData;

  List<AssetType> visibleAssetTypes = [];

  bool isLoading = true;
  String? errorMessage;

  int currentPage = 1;
  int rowsPerPage = 10;
  int totalPages = 1;
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAssetTypes();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssetTypes({String? searchText}) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _assetTypeApiService.getAssetTypes(
        searchText: searchText,
        page: currentPage,
        sizePerPage: rowsPerPage,
        currentIndex: (currentPage - 1) * rowsPerPage,
      );

      if (!mounted) return;

      setState(() {
        assetTypeData = result;

        visibleAssetTypes = List<AssetType>.from(result.data);

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

  Future<void> _showAddAssetTypeDialog() async {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();

    bool isCritical = true;
    bool isCreating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> createAssetType() async {
              final code = codeController.text.trim();
              final name = nameController.text.trim();
              final category = categoryController.text.trim();
              final description = descriptionController.text.trim();

              if (code.isEmpty) {
                _showError('Asset Type Code is required');
                return;
              }

              if (name.isEmpty) {
                _showError('Asset Type Name is required');
                return;
              }

              if (category.isEmpty) {
                _showError('Category is required');
                return;
              }

              setDialogState(() {
                isCreating = true;
              });

              try {
                await _assetTypeApiService.createAssetType({
                  'asset_type_code': code,
                  'asset_type_name': name,
                  'category': category,
                  'description': description,
                  'is_critical': isCritical,
                });

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadAssetTypes(
                  searchText: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Asset Type created successfully'),
                  ),
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
                width: 650,
                constraints: const BoxConstraints(
                  maxWidth: 650,
                  maxHeight: 400,
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
                                  'Add Asset Type',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Create a new asset type and configure its details',
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
                                    label: 'Asset Type Code',
                                    controller: codeController,
                                    icon: Icons.tag_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildField(
                                    label: 'Asset Type Name',
                                    controller: nameController,
                                    icon: Icons.inventory_2_outlined,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'Category',
                                    controller: categoryController,
                                    icon: Icons.category_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildField(
                                    label: 'Description',
                                    controller: descriptionController,
                                    icon: Icons.description_outlined,
                                  ),
                                ),
                              ],
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
                                    Icons.warning_amber_outlined,
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
                                          'Is Critical',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Mark this asset type as critical',
                                          style: TextStyle(
                                            color: Color(0xff697482),
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isCritical,
                                    onChanged: isCreating
                                        ? null
                                        : (value) {
                                            setDialogState(() {
                                              isCritical = value;
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
                            onPressed: isCreating ? null : createAssetType,
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
                              isCreating ? 'Creating...' : 'Create Asset Type',
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

    codeController.dispose();
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
  }

  void _showDeleteDialog(AssetType assetType) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff202b39),

          title: const Text(
            'Delete Asset Type',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          content: Text(
            'Are you sure you want to delete '
            '${assetType.assetTypeName}?',
            style: const TextStyle(color: Color(0xff8994a2), fontSize: 11),
          ),

          actions: [
            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xff8994a2)),
              ),
            ),

            // DELETE
            ElevatedButton(
              onPressed: () async {
                // Close the dialog using the dialog context
                Navigator.pop(dialogContext);

                try {
                  await _assetTypeApiService.deleteAssetType(assetType.id);

                  if (!mounted) return;

                  await _loadAssetTypes(
                    searchText: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Asset Type deleted successfully'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete asset type: '
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
                    'Asset Types',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Manage asset types and their configuration',
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

                                _loadAssetTypes(
                                  searchText: value.trim().isEmpty
                                      ? null
                                      : value.trim(),
                                );
                              },
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search asset types...',
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
                          onPressed: _showAddAssetTypeDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Add Asset Type',
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
              'Unable to load asset types',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadAssetTypes,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (visibleAssetTypes.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAssetTypeTable();
  }

  Widget _buildAssetTypeTable() {
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

                    // Removes ALL table lines
                    border: const TableBorder(
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                      horizontalInside: BorderSide.none,
                      verticalInside: BorderSide.none,
                    ),

                    columns: const [
                      DataColumn(label: Text('ASSET TYPE CODE')),
                      DataColumn(label: Text('ASSET TYPE NAME')),
                      DataColumn(label: Text('CATEGORY')),
                      DataColumn(label: Text('DESCRIPTION')),
                      DataColumn(label: Text('CRITICAL')),
                      DataColumn(label: Text('ACTIONS')),
                    ],

                    rows: visibleAssetTypes.map((asset) {
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                asset.assetTypeCode,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text(
                                asset.assetTypeName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              width: 160,
                              child: Text(
                                asset.category,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              width: 260,
                              child: Text(
                                asset.description,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          DataCell(_buildCriticalStatus(asset.isCritical)),

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
                                        return AssetTypeCRUDUpdate(
                                          assetType: asset,
                                        );
                                      },
                                    );

                                    if (result == true) {
                                      await _loadAssetTypes(
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

        // BUTTON
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

        // ARROW
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 17,
            color: Color(0xff8994a2),
          ),
        ),

        style: const TextStyle(color: Color(0xff8994a2), fontSize: 11),

        underline: const SizedBox(),

        // POPUP
        dropdownStyleData: DropdownStyleData(
          width: 70,

          // Same positioning as UserCRUD
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

          await _loadAssetTypes(
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

                await _loadAssetTypes(
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

                await _loadAssetTypes(
                  searchText: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                );
              },
            ),

            const SizedBox(width: 20),

            Text(
              'Page $currentPage of $totalPages · '
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

              await _loadAssetTypes(
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

  Widget _buildCriticalStatus(bool critical) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: critical
            ? const Color(0xffdc2626).withOpacity(0.10)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        critical ? 'Critical' : 'Non-Critical',
        style: TextStyle(
          color: critical ? const Color(0xffff6b6b) : const Color(0xff8994a2),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // FIELD
  // ============================================================

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

  // ============================================================
  // ACTION BUTTON
  // ============================================================

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

  // ============================================================
  // EMPTY STATE
  // ============================================================

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
            'No asset types found',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            'There are no asset types available.',
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
