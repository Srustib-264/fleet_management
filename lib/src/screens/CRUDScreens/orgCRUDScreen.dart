import 'package:flutter/material.dart';

import '../../models/orgCRUDModel.dart';
import '../../services/CRUDServices/orgCRUDAPIService.dart';
import '../forms/orgCRUDUpdate.dart';

class OrgCRUDScreen extends StatefulWidget {
  const OrgCRUDScreen({super.key});

  @override
  State<OrgCRUDScreen> createState() => _OrgCRUDScreenState();
}

class _OrgCRUDScreenState extends State<OrgCRUDScreen> {
  final OrgApiService _orgApiService = OrgApiService();

  List<OrgData> organizations = [];

  bool isLoading = true;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  // ============================================================
  // GET ORGANIZATIONS
  // ============================================================

  Future<void> _loadOrganizations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _orgApiService.getOrganizations();

      if (!mounted) return;

      setState(() {
        organizations = response.data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showSnackBar('Failed to load organizations', isError: true);
    }
  }

  // ============================================================
  // DELETE ORGANIZATION
  // ============================================================

  Future<void> _deleteOrganization(OrgData organization) async {
    if (organization.id == null || organization.id!.isEmpty) {
      _showSnackBar('Organization ID is missing', isError: true);
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff202b39),

          title: const Text(
            'Delete Organization',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "${organization.orgName ?? 'this organization'}"?',
            style: const TextStyle(color: Color(0xff8994a2), fontSize: 12),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xff8994a2)),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isDeleting = true;
    });

    try {
      await _orgApiService.deleteOrganization(organization.id!);

      if (!mounted) return;

      _showSnackBar('Organization deleted successfully');

      await _loadOrganizations();
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Failed to delete organization', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  Future<void> _showAddOrganizationDialog() async {
    // final orgCodeController = TextEditingController();
    final orgNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final contactPersonController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    String selectedStatus = 'active';
    bool isAdding = false;

    const Color dialogColor = Color(0xff202b39);
    const Color fieldColor = Color(0xff141d28);
    const Color primaryColor = Color(0xff078df5);
    const Color secondaryTextColor = Color(0xff8994a2);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> addOrganization() async {
              if (orgNameController.text.trim().isEmpty) {
                _showSnackBar('Organization name is required', isError: true);
                return;
              }

              setDialogState(() {
                isAdding = true;
              });

              final Map<String, dynamic> organizationData = {
                // 'org_code': int.tryParse(orgCodeController.text.trim()),
                'org_name': orgNameController.text.trim(),
                'description': descriptionController.text.trim(),
                'contact_person': contactPersonController.text.trim(),
                'email': emailController.text.trim(),
                'phone': phoneController.text.trim(),
                'address': addressController.text.trim(),
                'status': selectedStatus,
              };

              try {
                await _orgApiService.addOrganization(organizationData);

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadOrganizations();

                if (!mounted) return;

                _showSnackBar('Organization added successfully');
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isAdding = false;
                });

                _showSnackBar('Failed to add organization: $e', isError: true);
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,

              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 25,
              ),

              child: Container(
                width: 720,

                constraints: const BoxConstraints(
                  maxWidth: 650,
                  maxHeight: 650,
                ),

                decoration: BoxDecoration(
                  color: dialogColor,

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
                    // =====================================================
                    // HEADER
                    // =====================================================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),

                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,

                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.12),

                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: const Icon(
                              Icons.business_outlined,
                              color: primaryColor,
                              size: 21,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  'Add Organization',

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  'Create a new organization and add its contact details',

                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: isAdding
                                ? null
                                : () {
                                    Navigator.pop(dialogContext);
                                  },

                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.white.withOpacity(0.07)),

                    // =====================================================
                    // BODY
                    // =====================================================
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // =================================================
                            // BASIC INFORMATION
                            // =================================================
                            // _buildOrganizationSectionTitle(
                            //   icon: Icons.business_outlined,
                            //   title: 'Organization Information',
                            //   subtitle: 'Enter the basic organization details',
                            // ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                // Expanded(
                                //   child: _buildOrganizationDialogField(
                                //     label: 'Organization Code',
                                //     hint: 'Enter organization code',
                                //     controller: orgCodeController,
                                //     icon: Icons.tag_outlined,
                                //     keyboardType: TextInputType.number,
                                //     fieldColor: fieldColor,
                                //     primaryColor: primaryColor,
                                //     secondaryTextColor: secondaryTextColor,
                                //   ),
                                // ),
                                // const SizedBox(width: 14),
                                Expanded(
                                  child: _buildOrganizationDialogField(
                                    label: 'Organization Name',
                                    hint: 'Enter organization name',
                                    controller: orgNameController,
                                    icon: Icons.business_outlined,
                                    fieldColor: fieldColor,
                                    primaryColor: primaryColor,
                                    secondaryTextColor: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            _buildOrganizationDialogField(
                              label: 'Description',
                              hint: 'Enter organization description',
                              controller: descriptionController,
                              icon: Icons.description_outlined,
                              maxLines: 3,
                              fieldColor: fieldColor,
                              primaryColor: primaryColor,
                              secondaryTextColor: secondaryTextColor,
                            ),

                            // =================================================
                            // CONTACT INFORMATION
                            // =================================================
                            // _buildOrganizationSectionTitle(
                            //   icon: Icons.contact_phone_outlined,
                            //   title: 'Contact Information',
                            //   subtitle: 'Add the primary contact details',
                            // ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: _buildOrganizationDialogField(
                                    label: 'Contact Person',
                                    hint: 'Enter contact person',
                                    controller: contactPersonController,
                                    icon: Icons.person_outline,
                                    fieldColor: fieldColor,
                                    primaryColor: primaryColor,
                                    secondaryTextColor: secondaryTextColor,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: _buildOrganizationDialogField(
                                    label: 'Email',
                                    hint: 'Enter email address',
                                    controller: emailController,
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    fieldColor: fieldColor,
                                    primaryColor: primaryColor,
                                    secondaryTextColor: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: _buildOrganizationDialogField(
                                    label: 'Phone',
                                    hint: 'Enter phone number',
                                    controller: phoneController,
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    fieldColor: fieldColor,
                                    primaryColor: primaryColor,
                                    secondaryTextColor: secondaryTextColor,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: _buildOrganizationDialogField(
                                    label: 'Address',
                                    hint: 'Enter organization address',
                                    controller: addressController,
                                    icon: Icons.location_on_outlined,
                                    maxLines: 2,
                                    fieldColor: fieldColor,
                                    primaryColor: primaryColor,
                                    secondaryTextColor: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),

                            // =================================================
                            // STATUS
                            // =================================================
                            // _buildOrganizationSectionTitle(
                            //   icon: Icons.settings_outlined,
                            //   title: 'Organization Status',
                            //   subtitle:
                            //       'Choose the current organization status',
                            // ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: fieldColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),

                              child: DropdownButtonFormField<String>(
                                value: selectedStatus,

                                dropdownColor: dialogColor,

                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: secondaryTextColor,
                                  size: 20,
                                ),

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                ),

                                decoration: const InputDecoration(
                                  labelText: 'Status',

                                  labelStyle: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12,
                                  ),

                                  border: InputBorder.none,

                                  prefixIcon: Icon(
                                    Icons.toggle_on_outlined,
                                    color: secondaryTextColor,
                                    size: 18,
                                  ),
                                ),

                                items: const [
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Text('Active'),
                                  ),

                                  DropdownMenuItem(
                                    value: 'inactive',
                                    child: Text('Inactive'),
                                  ),
                                ],

                                onChanged: isAdding
                                    ? null
                                    : (value) {
                                        if (value == null) {
                                          return;
                                        }

                                        setDialogState(() {
                                          selectedStatus = value;
                                        });
                                      },
                              ),
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
                            onPressed: isAdding
                                ? null
                                : () {
                                    Navigator.pop(dialogContext);
                                  },

                            child: const Text(
                              'Cancel',

                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton.icon(
                            onPressed: isAdding ? null : addOrganization,

                            icon: isAdding
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_business_outlined,
                                    size: 16,
                                  ),

                            label: Text(
                              isAdding ? 'Adding...' : 'Add Organization',
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,

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
          },
        );
      },
    );
    // orgCodeController.dispose();
    orgNameController.dispose();
    descriptionController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }
  // ============================================================
  // EDIT ORGANIZATION
  // ============================================================

  void _showEditOrganizationDialog(OrgData organization) {
    final orgCodeController = TextEditingController(
      text: organization.orgCode?.toString() ?? '',
    );

    final orgNameController = TextEditingController(
      text: organization.orgName ?? '',
    );

    final descriptionController = TextEditingController(
      text: organization.description ?? '',
    );

    final contactPersonController = TextEditingController(
      text: organization.contactPerson ?? '',
    );

    final emailController = TextEditingController(
      text: organization.email ?? '',
    );

    final phoneController = TextEditingController(
      text: organization.phone ?? '',
    );

    final addressController = TextEditingController(
      text: organization.address ?? '',
    );

    String selectedStatus = organization.status?.isNotEmpty == true
        ? organization.status!
        : 'active';

    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xff202b39),

              title: const Text(
                'Update Organization',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              content: SizedBox(
                width: 520,

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // _buildDialogField(
                      //   label: 'Organization Code',
                      //   controller: orgCodeController,
                      //   keyboardType: TextInputType.number,
                      // ),
                      _buildDialogField(
                        label: 'Organization Name',
                        controller: orgNameController,
                      ),

                      _buildDialogField(
                        label: 'Description',
                        controller: descriptionController,
                        maxLines: 3,
                      ),

                      _buildDialogField(
                        label: 'Contact Person',
                        controller: contactPersonController,
                      ),

                      _buildDialogField(
                        label: 'Email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      _buildDialogField(
                        label: 'Phone',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),

                      _buildDialogField(
                        label: 'Address',
                        controller: addressController,
                        maxLines: 2,
                      ),

                      _buildStatusDropdown(
                        value: selectedStatus,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xff8994a2)),
                  ),
                ),

                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (organization.id == null ||
                              organization.id!.isEmpty) {
                            _showSnackBar(
                              'Organization ID is missing',
                              isError: true,
                            );
                            return;
                          }

                          if (orgNameController.text.trim().isEmpty) {
                            _showSnackBar(
                              'Organization name is required',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() {
                            isUpdating = true;
                          });

                          final Map<String, dynamic> updateData = {
                            'org_code': int.tryParse(
                              orgCodeController.text.trim(),
                            ),

                            'org_name': orgNameController.text.trim(),

                            'description': descriptionController.text.trim(),

                            'contact_person': contactPersonController.text
                                .trim(),

                            'email': emailController.text.trim(),

                            'phone': phoneController.text.trim(),

                            'address': addressController.text.trim(),

                            'status': selectedStatus,
                          };

                          try {
                            await _orgApiService.updateOrganization(
                              organization.id!,
                              updateData,
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            _showSnackBar('Organization updated successfully');

                            await _loadOrganizations();
                          } catch (e) {
                            setDialogState(() {
                              isUpdating = false;
                            });

                            _showSnackBar(
                              'Failed to update organization: $e',
                              isError: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff078df5),
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget _buildOrganizationSectionTitle({
  //   required IconData icon,
  //   required String title,
  //   required String subtitle,
  // }) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         width: 34,
  //         height: 34,

  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.05),
  //           borderRadius: BorderRadius.circular(8),
  //         ),

  //         child: Icon(icon, size: 17, color: const Color(0xff8994a2)),
  //       ),

  //       const SizedBox(width: 11),

  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),

  //             const SizedBox(height: 3),

  //             Text(
  //               subtitle,
  //               style: const TextStyle(color: Color(0xff8994a2), fontSize: 10),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildOrganizationDialogField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color fieldColor,
    required Color primaryColor,
    required Color secondaryTextColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,

        keyboardType: keyboardType,

        maxLines: maxLines,

        style: const TextStyle(color: Colors.white, fontSize: 12.5),

        cursorColor: primaryColor,

        decoration: InputDecoration(
          labelText: label,

          hintText: hint,

          hintStyle: const TextStyle(color: Color(0xff596575), fontSize: 10.5),

          labelStyle: TextStyle(color: secondaryTextColor, fontSize: 12),

          floatingLabelStyle: TextStyle(color: primaryColor, fontSize: 12),

          prefixIcon: Icon(icon, size: 17, color: secondaryTextColor),

          filled: true,

          fillColor: fieldColor,

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
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
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

          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
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
                    'Organizations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Manage your organizations',
                    style: TextStyle(color: Color(0xff8994a2), fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            ElevatedButton.icon(
              onPressed: _showAddOrganizationDialog,
              icon: const Icon(Icons.add, size: 17),
              label: const Text(
                'Add Organization',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff078df5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // ========================================================
        // TABLE
        // ========================================================
        Expanded(
          child: Container(
            width: double.infinity,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),

              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),

            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff078df5),
                      strokeWidth: 2,
                    ),
                  )
                : organizations.isEmpty
                ? _buildEmptyState()
                : _buildOrganizationTable(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ORGANIZATION TABLE
  // ============================================================

  Widget _buildOrganizationTable() {
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

                      columns: const [
                        DataColumn(label: Text('CODE')),

                        DataColumn(label: Text('ORGANIZATION')),

                        DataColumn(label: Text('CONTACT PERSON')),

                        DataColumn(label: Text('EMAIL')),

                        DataColumn(label: Text('PHONE')),

                        DataColumn(label: Text('STATUS')),

                        DataColumn(label: Text('ACTIONS')),
                      ],

                      rows: organizations.map((organization) {
                        final bool active =
                            organization.status?.toLowerCase() == 'active';

                        return DataRow(
                          cells: [
                            // =================================================
                            // CODE
                            // =================================================
                            DataCell(
                              SizedBox(
                                width: 100,

                                child: Text(
                                  organization.orgCode?.toString() ?? '-',

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // =================================================
                            // ORGANIZATION
                            // =================================================
                            DataCell(
                              SizedBox(
                                width: 180,

                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        organization.orgName ?? '-',

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

                            // =================================================
                            // CONTACT PERSON
                            // =================================================
                            DataCell(
                              SizedBox(
                                width: 170,

                                child: Text(
                                  organization.contactPerson ?? '-',

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // =================================================
                            // EMAIL
                            // =================================================
                            DataCell(
                              SizedBox(
                                width: 200,

                                child: Text(
                                  organization.email ?? '-',

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // =================================================
                            // PHONE
                            // =================================================
                            DataCell(
                              SizedBox(
                                width: 140,

                                child: Text(
                                  organization.phone ?? '-',

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // =================================================
                            // STATUS
                            // =================================================
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(
                                          0xff16a34a,
                                        ).withOpacity(0.10)
                                      : Colors.white.withOpacity(0.05),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Text(
                                  active ? 'Active' : 'Inactive',

                                  style: TextStyle(
                                    color: active
                                        ? const Color(0xff4ade80)
                                        : const Color(0xff8994a2),

                                    fontSize: 9,

                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // =================================================
                            // ACTIONS
                            // =================================================
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  _buildActionButton(
                                    icon: Icons.edit_outlined,

                                    tooltip: 'Edit',

                                    color: const Color(0xff078df5),

                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return OrgCRUDUpdate(
                                            organization: organization,
                                            onUpdated: () async {
                                              await _loadOrganizations();
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(width: 20),

                                  _buildActionButton(
                                    icon: Icons.delete_outline,

                                    tooltip: 'Delete',

                                    color: Colors.red,

                                    onPressed: isDeleting
                                        ? () {}
                                        : () {
                                            _deleteOrganization(organization);
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
  // ORGANIZATION ROW
  // ============================================================

  Widget _buildOrganizationRow(OrgData organization) {
    return Container(
      height: 58,

      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
      ),

      child: Row(
        children: [
          _buildDataCell(organization.orgCode?.toString() ?? '-', width: 100),

          _buildDataCell(organization.orgName ?? '-', width: 180, bold: true),

          _buildDataCell(organization.contactPerson ?? '-', width: 170),

          _buildDataCell(organization.email ?? '-', width: 200),

          _buildDataCell(organization.phone ?? '-', width: 140),

          _buildStatusCell(organization.status ?? '-', width: 100),

          SizedBox(
            width: 110,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Edit',

                  onPressed: () {
                    _showEditOrganizationDialog(organization);
                  },

                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                    color: Color(0xff078df5),
                  ),
                ),

                IconButton(
                  tooltip: 'Delete',

                  onPressed: isDeleting
                      ? null
                      : () {
                          _deleteOrganization(organization);
                        },

                  icon: const Icon(
                    Icons.delete_outline,
                    size: 17,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 55,
            height: 55,

            decoration: BoxDecoration(
              color: const Color(0xff078df5).withOpacity(0.08),

              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.business_outlined,
              color: Color(0xff078df5),
              size: 25,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No organizations found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Add an organization to get started',
            style: TextStyle(color: Color(0xff697482), fontSize: 10),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: _showAddOrganizationDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Add Organization',
              style: TextStyle(fontSize: 11),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff078df5),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER CELL
  // ============================================================

  Widget _buildHeaderCell(String text, {required double width}) {
    return SizedBox(
      width: width,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),

        child: Align(
          alignment: Alignment.centerLeft,

          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: Color(0xff697482),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATA CELL
  // ============================================================

  Widget _buildDataCell(
    String text, {
    required double width,
    bool bold = false,
  }) {
    return SizedBox(
      width: width,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),

        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: bold ? Colors.white : const Color(0xff8994a2),
            fontSize: 10,
            fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CELL
  // ============================================================

  Widget _buildStatusCell(String status, {required double width}) {
    final bool active = status.toLowerCase() == 'active';

    return SizedBox(
      width: width,

      child: Align(
        alignment: Alignment.centerLeft,

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),

          decoration: BoxDecoration(
            color: active
                ? Colors.green.withOpacity(0.10)
                : Colors.red.withOpacity(0.10),

            borderRadius: BorderRadius.circular(5),
          ),

          child: Text(
            status,
            style: TextStyle(
              color: active ? Colors.greenAccent : Colors.redAccent,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG FIELD
  // ============================================================

  Widget _buildDialogField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,

        keyboardType: keyboardType,

        maxLines: maxLines,

        style: const TextStyle(color: Colors.white, fontSize: 12),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 11),

          filled: true,

          fillColor: const Color(0xff18222e),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),

            borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),

            borderSide: const BorderSide(color: Color(0xff078df5)),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS DROPDOWN
  // ============================================================

  Widget _buildStatusDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: DropdownButtonFormField<String>(
        value: value,

        dropdownColor: const Color(0xff18222e),

        style: const TextStyle(color: Colors.white, fontSize: 12),

        decoration: InputDecoration(
          labelText: 'Status',

          labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 11),

          filled: true,

          fillColor: const Color(0xff18222e),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),

            borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),

            borderSide: const BorderSide(color: Color(0xff078df5)),
          ),
        ),

        items: const [
          DropdownMenuItem(value: 'active', child: Text('Active')),

          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
        ],

        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 11)),

          backgroundColor: isError
              ? Colors.red.shade700
              : const Color(0xff202b39),

          behavior: SnackBarBehavior.floating,

          duration: const Duration(seconds: 2),
        ),
      );
  }
}
