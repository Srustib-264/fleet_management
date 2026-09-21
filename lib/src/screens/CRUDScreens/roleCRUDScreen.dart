import 'package:flutter/material.dart';

import '../../models/roleCRUDModel.dart';
import '../../services/CRUDServices/roleCRUDApiService.dart';

class RoleCRUDScreen extends StatefulWidget {
  const RoleCRUDScreen({super.key});

  @override
  State<RoleCRUDScreen> createState() => _RoleCRUDScreenState();
}

class _RoleCRUDScreenState extends State<RoleCRUDScreen> {
  final RoleCRUDAPIService _roleApiService = RoleCRUDAPIService();

  List<RoleData> roles = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    _loadRoles();
  }

  Future<void> _loadRoles() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await _roleApiService.getRoles();

      if (!mounted) return;

      setState(() {
        roles = result.data ?? [];
        isLoading = false;
      });

      for (final role in roles) {}
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _showAddRoleDialog() async {
    final roleCodeController = TextEditingController();
    final roleNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final hierarchyController = TextEditingController();

    bool isSystemRole = false;
    bool isCreating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> createRole() async {
              final roleName = roleNameController.text.trim();
              final description = descriptionController.text.trim();

              if (roleName.isEmpty) {
                _showError('Role Name is required');
                return;
              }

              final int? roleCode = int.tryParse(
                roleCodeController.text.trim(),
              );

              if (roleCodeController.text.trim().isNotEmpty &&
                  roleCode == null) {
                _showError('Role Code must be a number');
                return;
              }

              final int? hierarchyLevel = int.tryParse(
                hierarchyController.text.trim(),
              );

              if (hierarchyController.text.trim().isNotEmpty &&
                  hierarchyLevel == null) {
                _showError('Hierarchy Level must be a number');
                return;
              }

              setDialogState(() {
                isCreating = true;
              });

              try {
                await _roleApiService.createRole(
                  roleCode: roleCode ?? 0,
                  roleName: roleName,
                  description: description,
                  hierarchyLevel: hierarchyLevel ?? 0,
                  isSystemRole: isSystemRole,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadRoles();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role created successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isCreating = false;
                });

                _showError(e.toString().replaceFirst('Exception: ', ''));
              }
            }

            return _buildRoleDialog(
              context: context,
              title: 'Add Role',
              subtitle: 'Create a new role and configure access details',
              roleCodeController: roleCodeController,
              roleNameController: roleNameController,
              descriptionController: descriptionController,
              hierarchyController: hierarchyController,
              isSystemRole: isSystemRole,
              isLoading: isCreating,
              onSystemRoleChanged: (value) {
                setDialogState(() {
                  isSystemRole = value;
                });
              },
              onSave: createRole,
              saveText: 'Create Role',
              saveIcon: Icons.add_moderator_outlined,
              dialogContext: dialogContext,
            );
          },
        );
      },
    );

    roleCodeController.dispose();
    roleNameController.dispose();
    descriptionController.dispose();
    hierarchyController.dispose();
  }

  Future<void> _showEditRoleDialog(RoleData role) async {
    final roleCodeController = TextEditingController(
      text: role.roleCode?.toString() ?? '',
    );

    final roleNameController = TextEditingController(text: role.roleName ?? '');

    final descriptionController = TextEditingController(
      text: role.description ?? '',
    );

    final hierarchyController = TextEditingController(
      text: role.hierarchyLevel?.toString() ?? '',
    );

    bool isSystemRole = role.isSystemRole ?? false;
    bool isUpdating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> updateRole() async {
              if (role.id == null || role.id!.isEmpty) {
                _showError('Role ID is missing');
                return;
              }

              final roleName = roleNameController.text.trim();

              if (roleName.isEmpty) {
                _showError('Role Name is required');
                return;
              }

              final int? roleCode = int.tryParse(
                roleCodeController.text.trim(),
              );

              if (roleCode == null) {
                _showError('Role Code must be a number');
                return;
              }

              final int? hierarchyLevel = int.tryParse(
                hierarchyController.text.trim(),
              );

              if (hierarchyLevel == null) {
                _showError('Hierarchy Level must be a number');
                return;
              }

              setDialogState(() {
                isUpdating = true;
              });

              try {
                await _roleApiService.updateRole(
                  id: role.id!,
                  roleCode: roleCode,
                  roleName: roleName,
                  description: descriptionController.text.trim(),
                  hierarchyLevel: hierarchyLevel,
                  isSystemRole: isSystemRole,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadRoles();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role updated successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isUpdating = false;
                });

                _showError(e.toString().replaceFirst('Exception: ', ''));
              }
            }

            return _buildRoleDialog(
              context: context,
              title: 'Edit Role',
              subtitle: 'Update role and access details',
              roleCodeController: roleCodeController,
              roleNameController: roleNameController,
              descriptionController: descriptionController,
              hierarchyController: hierarchyController,
              isSystemRole: isSystemRole,
              isLoading: isUpdating,
              onSystemRoleChanged: (value) {
                setDialogState(() {
                  isSystemRole = value;
                });
              },
              onSave: updateRole,
              saveText: 'Update Role',
              saveIcon: Icons.save_outlined,
              dialogContext: dialogContext,
            );
          },
        );
      },
    );

    roleCodeController.dispose();
    roleNameController.dispose();
    descriptionController.dispose();
    hierarchyController.dispose();
  }

  Widget _buildRoleDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required TextEditingController roleCodeController,
    required TextEditingController roleNameController,
    required TextEditingController descriptionController,
    required TextEditingController hierarchyController,
    required bool isSystemRole,
    required bool isLoading,
    required ValueChanged<bool> onSystemRoleChanged,
    required VoidCallback onSave,
    required String saveText,
    required IconData saveIcon,
    required BuildContext dialogContext,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 700),
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
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Color(0xff078df5),
                      size: 21,
                    ),
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

            Divider(height: 1, color: Colors.white.withOpacity(0.07)),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'Role Name',
                      controller: roleNameController,
                      icon: Icons.badge_outlined,
                      readOnly: false,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Role Code',
                            controller: roleCodeController,
                            icon: Icons.tag_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'Hierarchy Level',
                            controller: hierarchyController,
                            icon: Icons.account_tree_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    _buildField(
                      label: 'Description',
                      controller: descriptionController,
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),

                    Container(
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
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
                            Icons.security_outlined,
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
                                  'System Role',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                SizedBox(height: 2),

                                Text(
                                  'Mark this role as a system role',
                                  style: TextStyle(
                                    color: Color(0xff697482),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Switch(
                            value: isSystemRole,
                            onChanged: isLoading ? null : onSystemRoleChanged,
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

            Divider(height: 1, color: Colors.white.withOpacity(0.07)),

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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 12.5),
        cursorColor: const Color(0xff078df5),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xff596575), fontSize: 11),
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

  void _showDeleteDialog(RoleData role) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff202b39),
          title: const Text(
            'Delete Role',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to delete '
            '${role.roleName ?? 'this role'}?',
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

                if (role.id == null || role.id!.isEmpty) {
                  _showError('Role ID is missing');
                  return;
                }

                try {
                  await _roleApiService.deleteRole(role.id!);

                  await _loadRoles();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Role deleted successfully')),
                  );
                } catch (e) {
                  if (!mounted) return;

                  _showError('Failed to delete role: $e');
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

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
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
          child: Icon(icon, size: 15, color: color ?? const Color(0xff078df5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Manage user roles and access levels',
                    style: TextStyle(color: Color(0xff8994a2), fontSize: 10),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: _showAddRoleDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Role',
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

        const SizedBox(height: 20),

        Expanded(child: _buildBody()),
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
              'Unable to load roles',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _loadRoles,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (roles.isEmpty) {
      return _buildEmptyState();
    }

    return _buildRoleTable();
  }

  Widget _buildRoleTable() {
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
                      columnSpacing: 30,
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
                        DataColumn(label: Text('ROLE CODE')),

                        DataColumn(label: Text('ROLE NAME')),
                        DataColumn(label: Text('HIERARCHY LEVEL')),

                        DataColumn(label: Text('DESCRIPTION')),

                        DataColumn(label: Text('ACTIONS')),
                      ],

                      rows: roles.map((role) {
                        return DataRow(
                          cells: [
                            // ====================================
                            // ROLE CODE
                            // ====================================
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Text(
                                  role.roleCode?.toString() ?? '-',
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
                                width: 180,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        role.roleName ?? '-',
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
                            DataCell(
                              SizedBox(
                                width: 300,
                                child: Text(
                                  role.hierarchyLevel?.toString() ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,

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
                                width: 300,
                                child: Text(
                                  role.description ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildActionButton(
                                    icon: Icons.edit_outlined,
                                    tooltip: 'Edit',
                                    color: const Color(0xff078df5),
                                    onPressed: () {
                                      _showEditRoleDialog(role);
                                    },
                                  ),

                                  const SizedBox(width: 20),

                                  _buildActionButton(
                                    icon: Icons.delete_outline,
                                    tooltip: 'Delete',
                                    color: const Color(0xffdc2626),
                                    onPressed: () {
                                      _showDeleteDialog(role);
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

  Widget _buildSystemRoleStatus(bool isSystemRole) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isSystemRole
            ? const Color(0xff078df5).withOpacity(0.10)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isSystemRole ? 'System' : 'Custom',
        style: TextStyle(
          color: isSystemRole
              ? const Color(0xff60a5fa)
              : const Color(0xff8994a2),
          fontSize: 9,
          fontWeight: FontWeight.w500,
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
            Icons.admin_panel_settings_outlined,
            size: 38,
            color: Colors.white.withOpacity(0.20),
          ),

          const SizedBox(height: 12),

          const Text(
            'No roles found',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),

          const SizedBox(height: 6),

          const Text(
            'There are no roles available.',
            style: TextStyle(color: Color(0xff697482), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
