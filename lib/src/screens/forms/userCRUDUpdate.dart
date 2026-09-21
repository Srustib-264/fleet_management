import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/orgCRUDModel.dart';
import '../../models/usersCRUDModel.dart';
import '../../services/CRUDServices/orgCRUDApiService.dart';
import '../../services/CRUDServices/usersCRUDApiService.dart';

class UserUpdateCrudTable extends StatefulWidget {
  final Data user;

  const UserUpdateCrudTable({super.key, required this.user});

  @override
  State<UserUpdateCrudTable> createState() => _UserUpdateCrudTableState();
}

class _UserUpdateCrudTableState extends State<UserUpdateCrudTable> {
  final UserApiService _userApiService = UserApiService();

  late TextEditingController employeeCodeController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController profilePhotoController;
  late TextEditingController genderController;
  late TextEditingController dobController;
  // late TextEditingController organizationIdController;
  // late TextEditingController userRoleController;

  // NEW
  late TextEditingController passwordController;
  late TextEditingController statusController;

  bool isUpdating = false;

  bool obscurePassword = true;
  bool isActive = true;
  List<OrgData> organizations = [];
  OrgData? selectedOrganization;
  XFile? selectedProfileImage;
  String? selectedRoleId;
  static const Color dialogColor = Color(0xff202b39);
  static const Color fieldColor = Color(0xff141d28);
  static const Color primaryColor = Color(0xff078df5);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xff8994a2);
  @override
  void initState() {
    super.initState();

    employeeCodeController = TextEditingController(
      text: widget.user.employeeCode?.toString() ?? '',
    );

    firstNameController = TextEditingController(
      text: widget.user.firstName ?? '',
    );

    lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );

    fullNameController = TextEditingController(
      text: widget.user.fullName ?? '',
    );

    emailController = TextEditingController(text: widget.user.email ?? '');

    mobileController = TextEditingController(text: widget.user.mobile ?? '');

    profilePhotoController = TextEditingController(
      text: widget.user.profilePhoto ?? '',
    );

    genderController = TextEditingController(text: widget.user.gender ?? '');

    dobController = TextEditingController(text: _formatDate(widget.user.dob));

    // organizationIdController = TextEditingController(
    //   text: widget.user.organizationId?.toString() ?? '',
    // );

    // userRoleController = TextEditingController(
    //   text: widget.user.userRole?.toString() ?? '',
    // );
    selectedRoleId = widget.user.userRole?.toString();
    _loadOrganizations();
    passwordController = TextEditingController();

    statusController = TextEditingController(
      text: widget.user.status ?? 'active',
    );

    isActive = widget.user.isActive ?? false;
  }

  String _getRoleName(dynamic roleId) {
    if (roleId == null) {
      return '-';
    }

    const Map<String, String> roleNames = {
      '2': 'Super Admin',
      '4': 'Admin',
      '3': 'Manager',
      '5': 'Fleet Manager',
      '6': 'Route Manager',
      '7': 'Driver',
      '9': 'Viewer',
    };

    return roleNames[roleId.toString()] ?? 'Unknown Role';
  }

  String _formatDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return '';
    }

    final String value = date.trim();

    if (value.length >= 10) {
      final String datePart = value.substring(0, 10);

      final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

      if (dateRegex.hasMatch(datePart)) {
        return datePart;
      }
    }

    return value;
  }

  @override
  void dispose() {
    employeeCodeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    profilePhotoController.dispose();
    genderController.dispose();
    dobController.dispose();
    // organizationIdController.dispose();
    // userRoleController.dispose();

    // NEW
    passwordController.dispose();
    statusController.dispose();

    super.dispose();
  }

  Future<void> _loadOrganizations() async {
    try {
      final OrgApiService orgApiService = OrgApiService();

      final result = await orgApiService.getOrganizations();

      if (!mounted) return;

      final List<OrgData> loadedOrganizations = result.data ?? [];

      OrgData? currentOrganization;

      try {
        currentOrganization = loadedOrganizations.firstWhere(
          (org) => org.id?.toString() == widget.user.organizationId?.toString(),
        );
      } catch (_) {
        currentOrganization = null;
      }

      setState(() {
        organizations = loadedOrganizations;
        selectedOrganization = currentOrganization;
      });
    } catch (e) {
      if (!mounted) return;

      _showError('Failed to load organizations: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.bytes == null) {
        _showError('Unable to read selected image');
        return;
      }

      setState(() {
        selectedProfileImage = XFile.fromData(file.bytes!, name: file.name);

        profilePhotoController.text = file.name;
      });
    } catch (e) {
      _showError('Could not select image: $e');
    }
  }

  Future<void> _updateUser() async {
    if (widget.user.id == null || widget.user.id!.isEmpty) {
      _showError('User ID is missing');
      return;
    }

    if (firstNameController.text.trim().isEmpty) {
      _showError('First Name is required');
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      _showError('Last Name is required');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      _showError('Email is required');
      return;
    }
    if (selectedOrganization?.id == null) {
      _showError('Organization is required');
      return;
    }

    final int organizationId = int.parse(selectedOrganization!.id.toString());
    if (selectedRoleId == null) {
      _showError('User Role is required');
      return;
    }

    final int userRole = int.parse(selectedRoleId!);
    if (statusController.text.trim().isEmpty) {
      _showError('Status is required');
      return;
    }

    final String dob = dobController.text.trim();

    if (dob.isNotEmpty) {
      final RegExp dobRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

      if (!dobRegex.hasMatch(dob)) {
        _showError('Date of Birth must be YYYY-MM-DD');
        return;
      }

      try {
        DateTime.parse(dob);
      } catch (_) {
        _showError('Invalid Date of Birth');
        return;
      }
    }

    setState(() {
      isUpdating = true;
    });
    final String fullName = fullNameController.text.trim();

    final List<String> nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final String firstName = nameParts.isNotEmpty ? nameParts.first : '';

    final String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';
    final Map<String, dynamic> updateData = {
      'employee_code': int.tryParse(employeeCodeController.text.trim()),

      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'full_name': fullNameController.text.trim(),

      'email': emailController.text.trim(),

      'mobile': mobileController.text.trim(),

      'profile_photo': profilePhotoController.text.trim(),

      'gender': genderController.text.trim(),

      'dob': dob.isEmpty ? null : dob,

      'organization_id': organizationId,

      'user_role': userRole,

      // NEW
      'status': statusController.text.trim(),

      // NEW
      'is_active': isActive,
    };
    final String newPassword = passwordController.text.trim();

    if (newPassword.isNotEmpty) {
      updateData['password'] = newPassword;
    }
    try {
      await _userApiService.updateUser(
        widget.user.id!,
        updateData,
        profileImage: selectedProfileImage,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isUpdating = false;
      });

      _showError(
        'Failed to update user: '
        '${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();

    DateTime initialDate = DateTime(now.year - 18, now.month, now.day);

    // Open the calendar on the currently selected DOB
    if (dobController.text.trim().isNotEmpty) {
      try {
        initialDate = DateTime.parse(dobController.text.trim());

        // Make sure initialDate is within allowed range
        if (initialDate.isAfter(now)) {
          initialDate = now;
        }
      } catch (_) {
        initialDate = DateTime(now.year - 18, now.month, now.day);
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: dialogColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final String formattedDate =
          '${pickedDate.year.toString().padLeft(4, '0')}-'
          '${pickedDate.month.toString().padLeft(2, '0')}-'
          '${pickedDate.day.toString().padLeft(2, '0')}';

      setState(() {
        dobController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,

      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),

      child: Container(
        width: 720,

        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 780),

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
                      Icons.edit_outlined,
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
                          'Update User',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Edit the user information and save your changes',

                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            Navigator.pop(context);
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,

                    //   children: [
                    //     Expanded(
                    //       child: _buildField(
                    //         label: 'First Name',
                    //         controller: firstNameController,
                    //         icon: Icons.person_outline,
                    //       ),
                    //     ),

                    //     const SizedBox(width: 16),

                    //     Expanded(
                    //       child: _buildField(
                    //         label: 'Last Name',
                    //         controller: lastNameController,
                    //         icon: Icons.person_outline,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    _buildField(
                      label: 'Full Name',
                      controller: fullNameController,
                      icon: Icons.badge_outlined,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Employee Code',
                            controller: employeeCodeController,
                            icon: Icons.tag_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'Gender',
                            controller: genderController,
                            icon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Date of Birth',
                            controller: dobController,
                            icon: Icons.calendar_today_outlined,
                            hintText: 'YYYY-MM-DD',
                            readOnly: true,
                            onTap: isUpdating ? null : _pickDateOfBirth,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildField(
                            label: 'Mobile',
                            controller: mobileController,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    _buildField(
                      label: 'Email Address',
                      controller: emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 12),

                    //   child: TextField(
                    //     controller: passwordController,

                    //     obscureText: obscurePassword,

                    //     style: const TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 12.5,
                    //     ),

                    //     cursorColor: primaryColor,

                    //     decoration: InputDecoration(
                    //       labelText: 'Password',

                    //       hintText: 'Leave blank to keep current password',

                    //       hintStyle: const TextStyle(
                    //         color: Color(0xff596575),
                    //         fontSize: 10.5,
                    //       ),

                    //       labelStyle: const TextStyle(
                    //         color: secondaryTextColor,
                    //         fontSize: 12,
                    //       ),

                    //       floatingLabelStyle: const TextStyle(
                    //         color: primaryColor,
                    //         fontSize: 12,
                    //       ),

                    //       prefixIcon: const Icon(
                    //         Icons.lock_outline,
                    //         size: 17,
                    //         color: secondaryTextColor,
                    //       ),

                    //       suffixIcon: IconButton(
                    //         onPressed: isUpdating
                    //             ? null
                    //             : () {
                    //                 setState(() {
                    //                   obscurePassword = !obscurePassword;
                    //                 });
                    //               },

                    //         icon: Icon(
                    //           obscurePassword
                    //               ? Icons.visibility_outlined
                    //               : Icons.visibility_off_outlined,

                    //           size: 18,

                    //           color: secondaryTextColor,
                    //         ),
                    //       ),

                    //       filled: true,

                    //       fillColor: fieldColor,

                    //       contentPadding: const EdgeInsets.symmetric(
                    //         horizontal: 14,
                    //         vertical: 15,
                    //       ),

                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //         borderSide: BorderSide.none,
                    //       ),

                    //       enabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //         borderSide: BorderSide(
                    //           color: Colors.white.withOpacity(0.06),
                    //         ),
                    //       ),

                    //       focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //         borderSide: const BorderSide(color: primaryColor),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    _buildProfilePhoto(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= ORGANIZATION =================
                        Expanded(
                          child: DropdownButtonFormField2<OrgData>(
                            value: selectedOrganization,
                            isExpanded: true,

                            decoration: InputDecoration(
                              labelText: 'Organization',
                              labelStyle: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),

                              prefixIcon: const Icon(
                                Icons.business_outlined,
                                size: 17,
                                color: secondaryTextColor,
                              ),

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
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: primaryColor,
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
                              width: 320,

                              isOverButton: false,

                              offset: const Offset(0, -40),

                              padding: EdgeInsets.zero,

                              decoration: BoxDecoration(
                                color: dialogColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
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
                                color: secondaryTextColor,
                              ),
                            ),

                            items: organizations.map<DropdownMenuItem<OrgData>>(
                              (OrgData org) {
                                return DropdownMenuItem<OrgData>(
                                  value: org,
                                  child: Text(
                                    org.orgName ?? 'Unnamed Organization',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),

                            onChanged: isUpdating
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedOrganization = value;
                                    });
                                  },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // ================= USER ROLE =================
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            value: selectedRoleId,
                            isExpanded: true,

                            decoration: InputDecoration(
                              labelText: 'User Role',
                              labelStyle: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),

                              prefixIcon: const Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 17,
                                color: secondaryTextColor,
                              ),

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
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: primaryColor,
                                ),
                              ),
                            ),

                            hint: const Text(
                              'Select User Role',
                              style: TextStyle(
                                color: Color(0xff596575),
                                fontSize: 11,
                              ),
                            ),

                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 150,
                              width: 320,

                              // Dropdown below the field
                              isOverButton: false,

                              offset: const Offset(0, -40),

                              padding: EdgeInsets.zero,

                              decoration: BoxDecoration(
                                color: dialogColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
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
                                color: secondaryTextColor,
                              ),
                            ),

                            items: [
                              const DropdownMenuItem<String>(
                                value: '2',
                                child: Text(
                                  'Super Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const DropdownMenuItem<String>(
                                value: '4',
                                child: Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const DropdownMenuItem<String>(
                                value: '3',
                                child: Text(
                                  'Manager',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const DropdownMenuItem<String>(
                                value: '5',
                                child: Text(
                                  'Fleet Manager',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const DropdownMenuItem<String>(
                                value: '6',
                                child: Text(
                                  'Route Manager',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const DropdownMenuItem<String>(
                                value: '7',
                                child: Text(
                                  'Driver',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const DropdownMenuItem<String>(
                                value: '9',
                                child: Text(
                                  'Viewer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],

                            onChanged: isUpdating
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedRoleId = value;
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildActiveSwitch(),
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
                    onPressed: isUpdating
                        ? null
                        : () {
                            Navigator.pop(context);
                          },

                    child: const Text(
                      'Cancel',

                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    onPressed: isUpdating ? null : _updateUser,

                    icon: isUpdating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 16),

                    label: Text(isUpdating ? 'Updating...' : 'Update User'),

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
  }

  Widget _buildProfilePhoto() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Profile Photo',

            style: TextStyle(color: secondaryTextColor, fontSize: 12),
          ),

          const SizedBox(height: 7),

          Container(
            height: 72,

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            decoration: BoxDecoration(
              color: fieldColor,

              borderRadius: BorderRadius.circular(8),

              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),

            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,

                  decoration: BoxDecoration(
                    color: dialogColor,

                    borderRadius: BorderRadius.circular(7),
                  ),

                  child: selectedProfileImage != null
                      ? FutureBuilder<List<int>>(
                          future: selectedProfileImage!.readAsBytes(),

                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                ),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Icon(
                                Icons.image_outlined,
                                color: secondaryTextColor,
                              );
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(7),

                              child: Image.memory(
                                Uint8List.fromList(snapshot.data!),

                                width: 54,
                                height: 54,

                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.image_outlined,
                          color: secondaryTextColor,
                          size: 24,
                        ),
                ),

                const SizedBox(width: 12),

                // ==========================================
                // FILE NAME
                // ==========================================
                Expanded(
                  child: Text(
                    selectedProfileImage != null
                        ? selectedProfileImage!.name
                        : profilePhotoController.text.isNotEmpty
                        ? profilePhotoController.text.split('/').last
                        : 'No image selected',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(color: textColor, fontSize: 11.5),
                  ),
                ),

                const SizedBox(width: 10),

                // ==========================================
                // BROWSE
                // ==========================================
                OutlinedButton.icon(
                  onPressed: isUpdating ? null : _pickProfileImage,

                  icon: const Icon(Icons.folder_open_outlined, size: 16),

                  label: const Text('Browse', style: TextStyle(fontSize: 11)),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,

                    side: const BorderSide(color: primaryColor),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: secondaryTextColor,
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
                  'Enable user account',
                  style: TextStyle(color: Color(0xff697482), fontSize: 9),
                ),
              ],
            ),
          ),

          Switch(
            value: isActive,

            onChanged: isUpdating
                ? null
                : (value) {
                    setState(() {
                      isActive = value;
                    });
                  },

            activeColor: Colors.white,
            activeTrackColor: primaryColor,
            inactiveThumbColor: secondaryTextColor,
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
    TextInputType? keyboardType,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,

        // IMPORTANT
        readOnly: readOnly,
        onTap: onTap,

        style: const TextStyle(color: Colors.white, fontSize: 12.5),

        cursorColor: primaryColor,

        decoration: InputDecoration(
          labelText: label,

          hintText: hintText,

          hintStyle: const TextStyle(color: Color(0xff596575), fontSize: 11),

          labelStyle: const TextStyle(color: secondaryTextColor, fontSize: 12),

          floatingLabelStyle: const TextStyle(
            color: primaryColor,
            fontSize: 12,
          ),

          prefixIcon: Icon(icon, size: 17, color: secondaryTextColor),

          // Calendar icon
          suffixIcon: readOnly && onTap != null
              ? IconButton(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: primaryColor,
                  ),
                )
              : null,

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
            borderSide: const BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }
}
