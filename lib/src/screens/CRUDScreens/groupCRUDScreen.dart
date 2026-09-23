import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/groupCRUDModel.dart';
import '../../models/orgCRUDModel.dart';
import '../../services/CRUDServices/groupCRUDService.dart';
import '../../services/CRUDServices/orgCRUDApiService.dart';

class GroupCRUDScreen extends StatefulWidget {
  const GroupCRUDScreen({super.key});

  @override
  State<GroupCRUDScreen> createState() => _GroupCRUDScreenState();
}

class _GroupCRUDScreenState extends State<GroupCRUDScreen> {
  final GroupApiService _groupApiService = GroupApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  int currentPage = 1;
  int rowsPerPage = 10;
  int totalPages = 1;
  int totalCount = 0;
  GroupCRUDModel? groupData;

  bool isLoading = true;
  String? errorMessage;

  final OrgApiService _orgApiService = OrgApiService();

  OrgCRUDModel? organizationData;
  String organization_name = '--';
  String? organization_id;
  bool isOrganizationsLoading = false;
  String? organizationError;

  @override
  void initState() {
    super.initState();

    _loadGroups();
    _loadOrganizations();
    _loadOrganization();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganization() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      organization_name = prefs.getString('organization_name') ?? '--';
      organization_id = prefs.getString('organization_id');
    });
  }

  Future<void> _loadOrganizations() async {
    if (mounted) {
      setState(() {
        isOrganizationsLoading = true;
        organizationError = null;
      });
    }

    try {
      final result = await _orgApiService.getOrganizations();

      if (!mounted) return;

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

  Future<void> _loadGroups({String? searchText}) async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await _groupApiService.getGroups(
        searchText: searchText,
        page: currentPage,
        sizePerPage: rowsPerPage,
        currentIndex: (currentPage - 1) * rowsPerPage,
      );

      if (!mounted) return;

      setState(() {
        groupData = result;

        totalCount = result.pagination?.totalRecords ?? 0;
        totalPages = result.pagination?.totalPages ?? 1;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _getOrganizationName(String? organizationId) {
    if (organizationId == null || organizationId.isEmpty) {
      return '-';
    }

    final organizations = organizationData?.data ?? [];

    for (final organization in organizations) {
      if (organization.id?.toString() == organizationId) {
        return organization.orgName ?? '-';
      }
    }

    return organizationId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // HEADER
        // ========================================================
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Groups',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Manage groups and their organization details',
                    style: TextStyle(color: Color(0xff8994a2), fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            SizedBox(
              width: 260,
              height: 38,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                onChanged: (value) {
                  _searchDebounce?.cancel();

                  _searchDebounce = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      currentPage = 1;

                      final searchText = value.trim();

                      _loadGroups(
                        searchText: searchText.isEmpty ? null : searchText,
                      );
                    },
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search groups...',

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

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: Color(0xff078df5)),
                  ),
                ),
              ),
            ),

            const Spacer(),

            const SizedBox(width: 8),
            const Text(
              'Page :',
              style: TextStyle(color: Color(0xff8994a2), fontSize: 12),
            ),
            const SizedBox(width: 10),
            Container(
              width: 70,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xff202b39),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: DropdownButton2<int>(
                value: 10,
                isExpanded: true,

                buttonStyleData: ButtonStyleData(
                  width: 70,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff202b39),
                    borderRadius: BorderRadius.circular(7),
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

                // POPUP
                dropdownStyleData: DropdownStyleData(
                  width: 70,

                  offset: const Offset(0, -3),

                  // Fixed popup height
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

                  await _loadGroups(
                    searchText: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: _showAddGroupDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Group',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
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

        const SizedBox(height: 15),

        Expanded(child: _buildBody()),

        if (!isLoading) _buildPaginationControls(),
      ],
    );
  }

  // ============================================================
  // BODY
  // ============================================================

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
              'Unable to load groups',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _loadGroups,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff078df5),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Try Again', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    final data = groupData?.data ?? [];

    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGroupTable(data);
  }

  Widget _buildGroupTable(List<GroupData> data) {
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

            child: Scrollbar(
              thumbVisibility: true,

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

                      // ==================================================
                      // COLUMNS
                      // ==================================================
                      columns: const [
                        DataColumn(label: Text('GROUP CODE')),

                        DataColumn(label: Text('GROUP NAME')),

                        DataColumn(label: Text('DESCRIPTION')),

                        DataColumn(label: Text('ORGANIZATION')),

                        DataColumn(label: Text('ACTIONS')),
                      ],

                      // ==================================================
                      // ROWS
                      // ==================================================
                      rows: data.map((group) {
                        return DataRow(
                          cells: [
                            // ==========================================
                            // GROUP CODE
                            // ==========================================
                            DataCell(
                              SizedBox(
                                width: 140,

                                child: Text(
                                  group.groupCode?.toString() ?? '-',

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // ==========================================
                            // GROUP NAME
                            // ==========================================
                            DataCell(
                              SizedBox(
                                width: 200,

                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        group.groupName ?? '-',

                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ==========================================
                            // DESCRIPTION
                            // ==========================================
                            DataCell(
                              SizedBox(
                                width: 300,

                                child: Text(
                                  group.description ?? '-',

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // ==========================================
                            // ORGANIZATION
                            // ==========================================
                            DataCell(
                              SizedBox(
                                width: 180,

                                child: Text(
                                  _getOrganizationName(group.organizationId),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // ==========================================
                            // ACTIONS
                            // ==========================================
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  _buildActionButton(
                                    icon: Icons.edit_outlined,
                                    tooltip: 'Edit',
                                    color: const Color(0xff078df5),

                                    onPressed: () {
                                      _showEditGroupDialog(group);
                                    },
                                  ),

                                  const SizedBox(width: 20),

                                  _buildActionButton(
                                    icon: Icons.delete_outline,
                                    tooltip: 'Delete',
                                    color: const Color(0xffdc2626),

                                    onPressed: () {
                                      _showDeleteDialog(group);
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
    required Color color,
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

          child: Icon(icon, size: 15, color: color),
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
            Icons.groups_outlined,
            size: 38,
            color: Colors.white.withOpacity(0.20),
          ),

          const SizedBox(height: 12),

          const Text(
            'No groups found',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),

          const SizedBox(height: 6),

          const Text(
            'There are no groups available.',
            style: TextStyle(color: Color(0xff697482), fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIELD
  // ============================================================
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
              onTap: () {
                setState(() {
                  currentPage--;
                });

                _loadGroups(
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
              onTap: () {
                setState(() {
                  currentPage++;
                });

                _loadGroups(
                  searchText: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                );
              },
            ),

            const SizedBox(width: 20),

            SizedBox(
              width: 88,
              height: 26,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                decoration: InputDecoration(
                  hintText: 'Page',
                  hintStyle: const TextStyle(
                    color: Color(0xff697482),
                    fontSize: 11,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xff202b39),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    borderSide: BorderSide(color: Color(0xff078df5)),
                  ),
                ),
                onSubmitted: (value) {
                  final page = int.tryParse(value);

                  if (page == null) {
                    return;
                  }

                  if (page < 1 || page > totalPages) {
                    _showError('Please enter a page between 1 and $totalPages');
                    return;
                  }

                  setState(() {
                    currentPage = page;
                  });

                  _loadGroups(
                    searchText: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                  );
                },
              ),
            ),

            const SizedBox(width: 14),

            // ========================================
            // PAGE INFORMATION
            // ========================================
            Text(
              'Page $currentPage of $totalPages · $totalCount items',
              style: const TextStyle(
                color: Color(0xff8994a2),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
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

              await _loadGroups(
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

  Widget _buildGroupField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,

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

  Widget _buildOrganizationDropdown({
    required List<OrgData> organizations,
    required String? selectedOrganizationId,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField2<String>(
        value: selectedOrganizationId,
        isExpanded: true,

        decoration: InputDecoration(
          labelText: 'Organization',
          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 12),

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
          width: 664,

          // Opens over the dialog instead of pushing it
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

        items: organizations.map<DropdownMenuItem<String>>((
          OrgData organization,
        ) {
          return DropdownMenuItem<String>(
            value: organization.id,
            child: Text(
              organization.orgName ?? organization_name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }

  Future<void> _showAddGroupDialog() async {
    final prefs = await SharedPreferences.getInstance();

    final String? role = prefs.getString('role');
    final String? adminOrganizationId = prefs.getString('organization_id');

    final bool isAdmin = role?.trim().toLowerCase() == 'admin';

    if (isAdmin &&
        (adminOrganizationId == null || adminOrganizationId.isEmpty)) {
      _showError('Organization ID is missing');
      return;
    }

    String? selectedOrganizationId = isAdmin ? adminOrganizationId : null;

    final groupCodeController = TextEditingController();
    final groupNameController = TextEditingController();
    final descriptionController = TextEditingController();

    bool isCreating = false;

    if (!isAdmin && organizationData == null) {
      await _loadOrganizations();
    }

    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> createGroup() async {
              if (groupCodeController.text.trim().isEmpty) {
                _showError('Group Code is required');
                return;
              }

              final int? groupCode = int.tryParse(
                groupCodeController.text.trim(),
              );

              if (groupCode == null) {
                _showError('Group Code must be an integer');
                return;
              }

              if (groupNameController.text.trim().isEmpty) {
                _showError('Group Name is required');
                return;
              }

              if (selectedOrganizationId == null ||
                  selectedOrganizationId!.isEmpty) {
                _showError('Please select an organization');
                return;
              }

              setDialogState(() {
                isCreating = true;
              });

              final Map<String, dynamic> createData = {
                'group_code': groupCode,
                'group_name': groupNameController.text.trim(),
                'description': descriptionController.text.trim(),
                'organization_id': selectedOrganizationId,
              };

              try {
                await _groupApiService.createGroup(createData);

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadGroups();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group created successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isCreating = false;
                });

                _showError(e.toString().replaceFirst('Exception: ', ''));
              }
            }

            return _buildGroupDialog(
              context: context,
              dialogContext: dialogContext,
              title: 'Add Group',
              subtitle: 'Create a new group and assign it to an organization',
              icon: Icons.group_add_outlined,

              groupCodeController: groupCodeController,
              groupNameController: groupNameController,
              descriptionController: descriptionController,

              organizations: organizationData?.data ?? [],

              selectedOrganizationId: selectedOrganizationId,

              onOrganizationChanged: (value) {
                if (isAdmin) return;

                setDialogState(() {
                  selectedOrganizationId = value;
                });
              },

              isLoading: isCreating,
              onSave: createGroup,
              saveText: 'Create Group',
              saveIcon: Icons.add,
            );
          },
        );
      },
    );
  }
  // ============================================================
  // EDIT GROUP
  // ============================================================

  void _showEditGroupDialog(GroupData group) {
    final groupCodeController = TextEditingController(
      text: group.groupCode?.toString() ?? '',
    );

    final groupNameController = TextEditingController(
      text: group.groupName ?? '',
    );

    final descriptionController = TextEditingController(
      text: group.description ?? '',
    );

    String? selectedOrganizationId = group.organizationId;

    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> updateGroup() async {
              if (group.id == null || group.id!.isEmpty) {
                _showError('Group ID is missing');
                return;
              }

              if (groupCodeController.text.trim().isEmpty) {
                _showError('Group Code is required');
                return;
              }

              final int? groupCode = int.tryParse(
                groupCodeController.text.trim(),
              );

              if (groupCode == null) {
                _showError('Group Code must be an integer');
                return;
              }

              if (groupNameController.text.trim().isEmpty) {
                _showError('Group Name is required');
                return;
              }

              if (selectedOrganizationId == null ||
                  selectedOrganizationId!.isEmpty) {
                _showError('Please select an organization');
                return;
              }

              setDialogState(() {
                isUpdating = true;
              });

              final Map<String, dynamic> updateData = {
                'group_code': groupCode,
                'group_name': groupNameController.text.trim(),
                'description': descriptionController.text.trim(),
                'organization_id': selectedOrganizationId,
              };

              try {
                await _groupApiService.updateGroup(group.id!, updateData);

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadGroups();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group updated successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isUpdating = false;
                });

                _showError(e.toString().replaceFirst('Exception: ', ''));
              }
            }

            return _buildGroupDialog(
              context: context,
              dialogContext: dialogContext,
              title: 'Update Group',
              subtitle: 'Update group and organization details',
              icon: Icons.edit_outlined,

              groupCodeController: groupCodeController,
              groupNameController: groupNameController,
              descriptionController: descriptionController,
              organizations: organizationData?.data ?? [],
              selectedOrganizationId: selectedOrganizationId,

              onOrganizationChanged: (value) {
                setDialogState(() {
                  selectedOrganizationId = value;
                });
              },

              isLoading: isUpdating,
              onSave: updateGroup,
              saveText: 'Update Group',
              saveIcon: Icons.save_outlined,
            );
          },
        );
      },
    );
  }

  Widget _buildGroupDialog({
    required BuildContext context,
    required BuildContext dialogContext,
    required String title,
    required String subtitle,
    required IconData icon,
    required TextEditingController groupCodeController,
    required TextEditingController groupNameController,
    required TextEditingController descriptionController,
    required List<OrgData> organizations,
    // required TextEditingController organizationIdController,
    required String? selectedOrganizationId,
    required ValueChanged<String?> onOrganizationChanged,
    required bool isLoading,
    required VoidCallback onSave,
    required String saveText,
    required IconData saveIcon,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,

      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),

      child: Container(
        width: 720,

        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 400),

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

                    child: Icon(icon, color: const Color(0xff078df5), size: 21),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          title,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          subtitle,

                          style: const TextStyle(
                            color: Color(0xff8994a2),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: isLoading
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

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // GROUP CODE + NAME
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: _buildGroupField(
                            label: 'Group Code',
                            controller: groupCodeController,
                            icon: Icons.tag_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildGroupField(
                            label: 'Group Name',
                            controller: groupNameController,
                            icon: Icons.badge_outlined,
                          ),
                        ),
                      ],
                    ),

                    // DESCRIPTION
                    _buildGroupField(
                      label: 'Description',
                      controller: descriptionController,
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),

                    _buildOrganizationDropdown(
                      organizations: organizations,
                      selectedOrganizationId: selectedOrganizationId,
                      onChanged: onOrganizationChanged,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 15, 24, 15),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                          },

                    child: const Text(
                      'Cancel',

                      style: TextStyle(color: Color(0xff8994a2), fontSize: 12),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    onPressed: isLoading ? null : onSave,

                    icon: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(saveIcon, size: 16),

                    label: Text(isLoading ? 'Saving...' : saveText),

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

                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
  }

  void _showDeleteDialog(GroupData group) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff202b39),

          title: const Text(
            'Delete Group',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          content: Text(
            'Are you sure you want to delete '
            '${group.groupName ?? 'this group'}?',

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

                if (group.id == null || group.id!.isEmpty) {
                  _showError('Group ID is missing');
                  return;
                }

                try {
                  await _groupApiService.deleteGroup(group.id!);

                  await _loadGroups();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group deleted successfully')),
                  );
                } catch (e) {
                  if (!mounted) return;

                  _showError(
                    'Failed to delete group: '
                    '${e.toString().replaceFirst('Exception: ', '')}',
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffdc2626),
                foregroundColor: Colors.white,
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

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
