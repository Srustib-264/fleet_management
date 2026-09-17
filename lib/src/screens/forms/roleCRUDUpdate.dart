import 'package:flutter/material.dart';

import '../../models/roleCRUDModel.dart';
import '../../services/CRUDServices/roleCRUDApiService.dart';

class RoleCRUDUpdate extends StatefulWidget {
  final RoleData role;

  const RoleCRUDUpdate({super.key, required this.role});

  @override
  State<RoleCRUDUpdate> createState() => _RoleCRUDUpdateState();
}

class _RoleCRUDUpdateState extends State<RoleCRUDUpdate> {
  final RoleCRUDAPIService _roleApiService = RoleCRUDAPIService();

  late TextEditingController roleCodeController;
  late TextEditingController roleNameController;
  late TextEditingController descriptionController;
  late TextEditingController hierarchyController;

  bool isSystemRole = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    roleCodeController = TextEditingController(
      text: widget.role.roleCode?.toString() ?? '',
    );

    roleNameController = TextEditingController(
      text: widget.role.roleName ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.role.description ?? '',
    );

    hierarchyController = TextEditingController(
      text: widget.role.hierarchyLevel?.toString() ?? '',
    );

    isSystemRole = widget.role.isSystemRole ?? false;
  }

  @override
  void dispose() {
    roleCodeController.dispose();
    roleNameController.dispose();
    descriptionController.dispose();
    hierarchyController.dispose();

    super.dispose();
  }

  Future<void> _updateRole() async {
    final roleId = widget.role.id;

    if (roleId == null || roleId.isEmpty) {
      _showError('Role ID is missing');
      return;
    }

    final roleName = roleNameController.text.trim();

    if (roleName.isEmpty) {
      _showError('Role Name is required');
      return;
    }

    final roleCodeText = roleCodeController.text.trim();

    if (roleCodeText.isEmpty) {
      _showError('Role Code is required');
      return;
    }

    final roleCode = int.tryParse(roleCodeText);

    if (roleCode == null) {
      _showError('Role Code must be a number');
      return;
    }

    final hierarchyText = hierarchyController.text.trim();

    if (hierarchyText.isEmpty) {
      _showError('Hierarchy Level is required');
      return;
    }

    final hierarchyLevel = int.tryParse(hierarchyText);

    if (hierarchyLevel == null) {
      _showError('Hierarchy Level must be a number');
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final description = descriptionController.text.trim();

      final success = await _roleApiService.updateRole(
        id: roleId,
        roleCode: roleCode,
        roleName: roleName,
        description: description,
        hierarchyLevel: hierarchyLevel,
        isSystemRole: isSystemRole,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully')),
        );

        // Return true so the Roles page can refresh
        Navigator.pop(context, true);
      } else {
        setState(() {
          isUpdating = false;
        });

        _showError('Failed to update role');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });

      debugPrint('UPDATE ROLE ERROR: $e');

      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: !isUpdating,
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff111923),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              InkWell(
                onTap: isUpdating
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xff8994a2),
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Title
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Role',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Update role and access level details',
                      style: TextStyle(color: Color(0xff8994a2), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: 720,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xff202b39),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                  widget.role.roleName ?? 'Role',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Role ID: ${widget.role.id ?? '-'}',
                                  style: const TextStyle(
                                    color: Color(0xff697482),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Divider(height: 1, color: Colors.white.withOpacity(0.07)),

                      const SizedBox(height: 25),

                      _buildField(
                        label: 'Role Name',
                        controller: roleNameController,
                        icon: Icons.badge_outlined,
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
                        maxLines: 5,
                      ),

                      Container(
                        height: 68,
                        margin: const EdgeInsets.only(bottom: 25),
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
                                  SizedBox(height: 3),
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
                              onChanged: isUpdating
                                  ? null
                                  : (value) {
                                      setState(() {
                                        isSystemRole = value;
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isUpdating
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xff8994a2),
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          ElevatedButton.icon(
                            onPressed: isUpdating ? null : _updateRole,
                            icon: isUpdating
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined, size: 16),
                            label: Text(
                              isUpdating ? 'Updating...' : 'Update Role',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff078df5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
