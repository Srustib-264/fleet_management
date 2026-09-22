import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/orgCRUDModel.dart';
import '../../models/usersCRUDModel.dart';
import '../../services/CRUDServices/orgCRUDApiService.dart';
import '../../services/CRUDServices/usersCRUDApiService.dart';
import '../../services/apiUrl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../forms/userCRUDUpdate.dart';

class UserCRUDScreen extends StatefulWidget {
  const UserCRUDScreen({super.key});

  @override
  State<UserCRUDScreen> createState() => _UserCRUDScreenState();
}

class _UserCRUDScreenState extends State<UserCRUDScreen> {
  final UserApiService _userApiService = UserApiService();
  UserCRUDModel? userData;
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  List<OrgData> organizations = [];
  bool isLoading = true;
  String? errorMessage;
  List<Data> visibleUsers = [];
  // String? selectedRoleId;
  int currentPage = 1;
  int rowsPerPage = 10;
  int totalPages = 1;
  int totalCount = 0;
  // String currentSort = 'full_name_desc';
  String? currentSort;
  String? selectedRoleId;
  String? selectedFilterRoleId;

  final Map<String, String> roleNames = {
    '2': 'Super Admin',
    '4': 'Admin',
    '3': 'Manager',
    '5': 'Fleet Manager',
    '6': 'Route Manager',
    '7': 'Driver',
    '9': 'Viewer',
  };
  String _getRoleName(dynamic roleId) {
    if (roleId == null) {
      return '-';
    }
    return roleNames[roleId.toString()] ?? 'Unknown Role';
  }

  bool isSuperAdmin = false;
  bool isAdmin = false;

  String? adminOrganizationName;
  String? adminOrganizationId;
  String _getOrganizationName(String? organizationId) {
    if (organizationId == null || organizationId.isEmpty) {
      return '-';
    }

    try {
      final organization = organizations.firstWhere(
        (org) => org.id == organizationId,
      );

      return organization.orgName ?? '-';
    } catch (e) {
      return '-';
    }
  }

  @override
  void initState() {
    super.initState();

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadCurrentUserRole();

    await _loadUsers();

    if (!isAdmin) {
      await _loadOrganizations();
    }
  }

  String _getProfileImageUrl(String? profilePhoto) {
    if (profilePhoto == null || profilePhoto.trim().isEmpty) {
      return '';
    }

    final photo = profilePhoto.trim();

    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }

    final baseUrl = BaseURLConfig.baseURL;

    if (photo.startsWith('/')) {
      return '$baseUrl$photo';
    }

    return '$baseUrl/$photo';
  }

  Future<void> _loadCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();

    final String roleId = prefs.getString('role_id') ?? '';
    final String role = prefs.getString('role') ?? '';

    final String organizationName = prefs.getString('organization_name') ?? '';

    final String organizationId = prefs.getString('organization_id') ?? '';

    if (!mounted) return;

    setState(() {
      isSuperAdmin =
          roleId.trim() == '2' || role.trim().toUpperCase() == 'SUPER_ADMIN';

      isAdmin = roleId.trim() == '4' || role.trim().toUpperCase() == 'ADMIN';

      adminOrganizationName = organizationName;
      adminOrganizationId = organizationId;
    });
  }

  Future<void> _loadOrganizations() async {
    try {
      final OrgApiService orgApiService = OrgApiService();

      final result = await orgApiService.getOrganizations();

      if (!mounted) return;

      setState(() {
        organizations = result.data;
      });
    } catch (e) {}
  }

  Future<void> _loadUsers({String? roleId, String? searchText}) async {
    try {
      if (!mounted) return;

      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await _userApiService.getUsers(
        userRole: roleId,
        searchText: searchText,
        sort: currentSort,
        page: currentPage,
        sizePerPage: rowsPerPage,
        currentIndex: (currentPage - 1) * rowsPerPage,
      );

      final List<Data> allUsers = result.data ?? [];

      final List<Data> filteredUsers;

      if (isSuperAdmin) {
        filteredUsers = List<Data>.from(allUsers);
      } else {
        filteredUsers = allUsers.where((user) {
          final roleId = user.userRole?.toString().trim();
          return roleId != '2';
        }).toList();
      }

      if (!mounted) return;

      setState(() {
        userData = result;
        visibleUsers = filteredUsers;

        totalCount = result.pagination?.totalRecords ?? 0;

        totalPages = result.pagination?.totalPages ?? 1;

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

  Future<void> _showAddUserDialog() async {
    final OrgApiService orgApiService = OrgApiService();
    List<OrgData> organizations = [];

    if (isAdmin) {
      if (adminOrganizationId != null &&
          adminOrganizationId!.trim().isNotEmpty) {
        organizations = [
          OrgData(
            id: adminOrganizationId!,
            orgName: adminOrganizationName ?? '-',
          ),
        ];
      }
    } else {
      try {
        final result = await orgApiService.getOrganizations();
        organizations = result.data ?? [];
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load organizations: $e')),
          );
        }
      }
    }
    final employeeCodeController = TextEditingController();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    final genderController = TextEditingController();
    final dobController = TextEditingController();
    final passwordController = TextEditingController();
    // final userRoleController = TextEditingController();
    final statusController = TextEditingController(text: 'active');
    XFile? selectedProfileImage;
    OrgData? selectedOrganization;
    if (isAdmin && organizations.isNotEmpty) {
      selectedOrganization = organizations.first;
    }
    bool isCreating = false;
    bool obscurePassword = true;
    bool isActive = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDateOfBirth() async {
              final DateTime now = DateTime.now();

              DateTime initialDate = DateTime(
                now.year - 18,
                now.month,
                now.day,
              );

              if (dobController.text.trim().isNotEmpty) {
                try {
                  initialDate = DateTime.parse(dobController.text.trim());
                } catch (_) {}
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
                        primary: Color(0xff078df5),
                        onPrimary: Colors.white,
                        surface: Color(0xff202b39),
                        onSurface: Colors.white,
                      ),
                      dialogTheme: const DialogThemeData(
                        backgroundColor: Color(0xff202b39),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                print(
                  'CALENDAR SELECTED: ${pickedDate.year}-${pickedDate.month}-${pickedDate.day}',
                );

                final String formattedDate =
                    '${pickedDate.year.toString().padLeft(4, '0')}-'
                    '${pickedDate.month.toString().padLeft(2, '0')}-'
                    '${pickedDate.day.toString().padLeft(2, '0')}';

                print('DATE BEING SET: $formattedDate');

                setState(() {
                  dobController.text = formattedDate;
                });
              }
            }

            Future<void> pickProfileImage() async {
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

                setDialogState(() {
                  selectedProfileImage = XFile.fromData(
                    file.bytes!,
                    name: file.name,
                  );
                });
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not select image: $e')),
                );
              }
            }

            Future<void> createUser() async {
              final String fullName = fullNameController.text.trim();

              if (fullName.isEmpty) {
                _showError('Full Name is required');
                return;
              }

              final List<String> nameParts = fullName.split(RegExp(r'\s+'));

              if (nameParts.length < 2) {
                _showError('Please enter first name and last name');
                return;
              }

              final String firstName = nameParts.first;
              final String lastName = nameParts.sublist(1).join(' ');

              if (emailController.text.trim().isEmpty) {
                _showError('Email is required');
                return;
              }

              if (passwordController.text.trim().isEmpty) {
                _showError('Password is required');
                return;
              }
              if (selectedOrganization?.id == null) {
                _showError('Organization is required');
                return;
              }
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

              setDialogState(() {
                isCreating = true;
              });

              final Map<String, dynamic> createData = {
                'employee_code': int.tryParse(
                  employeeCodeController.text.trim(),
                ),

                'first_name': firstName,
                'last_name': lastName,
                'full_name': fullName,

                'email': emailController.text.trim(),

                'mobile': mobileController.text.trim(),

                'password': passwordController.text.trim(),

                'profile_photo': null,

                'gender': genderController.text.trim(),

                'dob': dob.isEmpty ? null : dob,

                'organization_id': selectedOrganization!.id,

                'user_role': userRole,

                'status': statusController.text.trim(),

                'is_active': isActive,
              };

              try {
                await _userApiService.createUser(
                  createData,
                  selectedProfileImage,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadUsers();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User created successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isCreating = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                  ),
                );
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
                  maxWidth: 720,
                  maxHeight: 780,
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
                              Icons.person_add_alt_1_outlined,
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
                                  'Add User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  'Create a new user and assign their access details',
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

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // ==========================================
                            // FIRST + LAST NAME
                            // ==========================================
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
                                    onTap: isCreating ? null : pickDateOfBirth,
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

                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),

                              child: TextField(
                                controller: passwordController,

                                obscureText: obscurePassword,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                ),

                                cursorColor: const Color(0xff078df5),

                                decoration: InputDecoration(
                                  labelText: 'Password',

                                  labelStyle: const TextStyle(
                                    color: Color(0xff8994a2),
                                    fontSize: 12,
                                  ),

                                  floatingLabelStyle: const TextStyle(
                                    color: Color(0xff078df5),
                                    fontSize: 12,
                                  ),

                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 17,
                                    color: Color(0xff8994a2),
                                  ),

                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },

                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 18,
                                      color: const Color(0xff8994a2),
                                    ),
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
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.only(bottom: 12),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
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
                                    Icons.image_outlined,
                                    size: 18,
                                    color: Color(0xff8994a2),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      selectedProfileImage?.name ??
                                          'Select image',

                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  OutlinedButton.icon(
                                    onPressed: isCreating
                                        ? null
                                        : pickProfileImage,

                                    icon: const Icon(
                                      Icons.folder_open_outlined,
                                      size: 15,
                                    ),

                                    label: const Text(
                                      'Browse',
                                      style: TextStyle(fontSize: 11),
                                    ),

                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xff078df5),

                                      side: const BorderSide(
                                        color: Color(0xff078df5),
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isAdmin) ...[
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.06,
                                            ),
                                          ),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                        width: 320,

                                        // IMPORTANT
                                        isOverButton: true,

                                        offset: const Offset(0, -50),

                                        padding: EdgeInsets.zero,

                                        decoration: BoxDecoration(
                                          color: const Color(0xff202b39),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
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
                                      menuItemStyleData:
                                          const MenuItemStyleData(
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
                                    child: DropdownButtonFormField2<String>(
                                      value: selectedRoleId,
                                      isExpanded: true,

                                      decoration: InputDecoration(
                                        labelText: 'User Role',
                                        labelStyle: const TextStyle(
                                          color: Color(0xff8994a2),
                                          fontSize: 12,
                                        ),

                                        prefixIcon: const Icon(
                                          Icons.admin_panel_settings_outlined,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.06,
                                            ),
                                          ),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xff078df5),
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

                                        // IMPORTANT
                                        isOverButton: true,

                                        offset: const Offset(0, -50),

                                        padding: EdgeInsets.zero,

                                        decoration: BoxDecoration(
                                          color: const Color(0xff202b39),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
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

                                      menuItemStyleData:
                                          const MenuItemStyleData(
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

                                      items: [
                                        if (isSuperAdmin)
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

                                      onChanged: isCreating
                                          ? null
                                          : (value) {
                                              setDialogState(() {
                                                selectedRoleId = value;
                                              });
                                            },
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                // Expanded(
                                //   child: _buildField(
                                //     label: 'Status',
                                //     controller: statusController,
                                //     icon: Icons.toggle_on_outlined,
                                //   ),
                                // ),

                                // const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
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
                                                'Enable user account',
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

                                          activeTrackColor: const Color(
                                            0xff078df5,
                                          ),

                                          inactiveThumbColor: const Color(
                                            0xff8994a2,
                                          ),

                                          inactiveTrackColor: const Color(
                                            0xff2b3745,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider(height: 1, color: Colors.white.withOpacity(0.07)),
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
                            onPressed: isCreating ? null : createUser,

                            icon: isCreating
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_add_outlined,
                                    size: 16,
                                  ),

                            label: Text(
                              isCreating ? 'Creating...' : 'Create User',
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

    employeeCodeController.dispose();
    // firstNameController.dispose();
    // lastNameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    genderController.dispose();
    dobController.dispose();
    passwordController.dispose();
    // userRoleController.dispose();
    statusController.dispose();
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,

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

          // Calendar icon on the right
          suffixIcon: readOnly && onTap != null
              ? IconButton(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Color(0xff078df5),
                  ),
                )
              : null,

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

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Users',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Manage users and their access',
                    style: TextStyle(color: Color(0xff8994a2), fontSize: 10),
                  ),

                  const SizedBox(height: 14),

                  // SEARCH + FILTER ROW
                  Row(
                    children: [
                      // SEARCH BAR
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
                            // Cancel previous timer
                            _searchDebounce?.cancel();

                            // Wait 500ms before calling API
                            _searchDebounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                final searchText = value.trim();

                                _loadUsers(
                                  roleId: selectedFilterRoleId,
                                  searchText: searchText.isEmpty
                                      ? null
                                      : searchText,
                                );
                              },
                            );
                          },

                          decoration: InputDecoration(
                            hintText: 'Search users...',

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
                              borderSide: const BorderSide(
                                color: Color(0xff078df5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // SELECT BY ROLE
                      Container(
                        width: 170,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xff202b39),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: DropdownButton2<String?>(
                          value: selectedFilterRoleId,
                          isExpanded: true,

                          // Main button
                          buttonStyleData: ButtonStyleData(
                            width: 170,
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff202b39),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),

                          hint: const Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 16,
                                color: Color(0xff8994a2),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Select by Role',
                                style: TextStyle(
                                  color: Color(0xff8994a2),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),

                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Color(0xff8994a2),
                            ),
                          ),

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),

                          underline: const SizedBox(),

                          dropdownStyleData: DropdownStyleData(
                            width: 170,

                            offset: const Offset(0, -3),

                            // Fixed dropdown height
                            maxHeight: 250,

                            padding: EdgeInsets.zero,

                            decoration: BoxDecoration(
                              color: const Color(0xff202b39),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                          // MENU ITEMS
                          menuItemStyleData: const MenuItemStyleData(
                            height: 42,
                            padding: EdgeInsets.symmetric(horizontal: 14),
                          ),

                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'All ',
                                style: TextStyle(
                                  color: Color(0xff8994a2),
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            ...roleNames.entries
                                .where(
                                  (entry) => isSuperAdmin || entry.key != '2',
                                )
                                .map(
                                  (entry) => DropdownMenuItem<String?>(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                          ],

                          onChanged: (value) async {
                            setState(() {
                              selectedFilterRoleId = value;
                              currentPage = 1;
                            });

                            await _loadUsers(
                              roleId: value,
                              searchText: _searchController.text.trim().isEmpty
                                  ? null
                                  : _searchController.text.trim(),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Spacer(),
                      const Text(
                        'Page :',
                        style: TextStyle(
                          color: Color(0xff8994a2),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 70,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xff202b39),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
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

                          style: const TextStyle(
                            color: Color(0xff8994a2),
                            fontSize: 11,
                          ),

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
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
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
                            DropdownMenuItem<int>(
                              value: 100,
                              child: Text('100'),
                            ),
                          ],

                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              rowsPerPage = value;
                              currentPage = 1;
                            });

                            await _loadUsers(
                              roleId: selectedFilterRoleId,
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
                          onPressed: () async {
                            _showAddUserDialog();
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Add User',
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
              'Unable to load users',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final data = visibleUsers;

    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return _buildUserTable(data);
  }

  Widget _buildUserTable(List<Data> data) {
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
                  data: DataTableThemeData(dividerThickness: 0),

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
                      border: TableBorder(
                        top: BorderSide.none,
                        bottom: BorderSide.none,
                        left: BorderSide.none,
                        right: BorderSide.none,

                        horizontalInside: BorderSide.none,
                        verticalInside: BorderSide.none,
                      ),

                      columns: [
                        DataColumn(label: Text('EMPLOYEE CODE')),

                        DataColumn(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('User Name'),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    currentSort = currentSort == 'full_name_asc'
                                        ? 'full_name_desc'
                                        : 'full_name_asc';

                                    currentPage = 1;
                                  });

                                  await _loadUsers();
                                },
                                borderRadius: BorderRadius.circular(7),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff202b39),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Icon(
                                    Icons.sort,
                                    size: 18,
                                    color: Color(0xff8994a2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataColumn(label: Text('EMAIL')),

                        DataColumn(label: Text('MOBILE')),

                        DataColumn(label: Text('ROLE')),

                        if (!isAdmin)
                          const DataColumn(label: Text('ORGANIZATION')),

                        DataColumn(label: Text('STATUS')),

                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: data.map((user) {
                        final bool active = user.isActive ?? false;

                        final String name =
                            user.fullName ??
                            '${user.firstName ?? ''} '
                                    '${user.lastName ?? ''}'
                                .trim();

                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 200,

                                child: Text(
                                  (user.employeeCode?.toString() ?? '-'),

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
                                    Container(
                                      width: 34,
                                      height: 34,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        color: const Color(0xff141d28),

                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                      ),

                                      child: ClipOval(
                                        child:
                                            user.profilePhoto != null &&
                                                user.profilePhoto!
                                                    .trim()
                                                    .isNotEmpty
                                            ? Image.network(
                                                _getProfileImageUrl(
                                                  user.profilePhoto,
                                                ),

                                                width: 34,
                                                height: 34,

                                                fit: BoxFit.cover,

                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.person_outline,
                                                        size: 18,
                                                        color: Color(
                                                          0xff8994a2,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : const Icon(
                                                Icons.person_outline,
                                                size: 18,
                                                color: Color(0xff8994a2),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        name.isEmpty ? '-' : name,

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
                                width: 200,

                                child: Text(
                                  user.email ?? '-',

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
                                width: 200,

                                child: Text(
                                  (user.mobile ?? '-'),

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
                                width: 200,

                                child: Text(
                                  _getRoleName(user.userRole),

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            if (!isAdmin)
                              DataCell(
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    _getOrganizationName(user.organizationId),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            DataCell(_buildStatus(active)),

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
                                          return UserUpdateCrudTable(
                                            user: user,
                                          );
                                        },
                                      );

                                      if (result == true) {
                                        await _loadUsers();
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 20),

                                  _buildActionButton(
                                    icon: Icons.delete_outline,
                                    tooltip: 'Delete',

                                    onPressed: () {
                                      _showDeleteDialog(user);
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

  Widget _buildStatus(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: active
            ? const Color(0xff16a34a).withOpacity(0.10)
            : Colors.white.withOpacity(0.05),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        active ? 'Active' : 'Inactive',

        style: TextStyle(
          color: active ? const Color(0xff4ade80) : const Color(0xff8994a2),

          fontSize: 9,

          fontWeight: FontWeight.w500,
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

          child: Icon(icon, size: 15, color: Colors.red),
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
            Icons.people_outline,
            size: 38,
            color: Colors.white.withOpacity(0.20),
          ),

          const SizedBox(height: 12),

          const Text(
            'No users found',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),

          const SizedBox(height: 6),

          const Text(
            'There are no users available.',
            style: TextStyle(color: Color(0xff697482), fontSize: 10),
          ),
        ],
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
              onTap: () {
                setState(() {
                  currentPage--;
                });

                _loadUsers(
                  roleId: selectedFilterRoleId,
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

                _loadUsers(
                  roleId: selectedFilterRoleId,
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

                  _loadUsers(
                    roleId: selectedFilterRoleId,
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

              await _loadUsers(
                roleId: selectedFilterRoleId,
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

  void _showDeleteDialog(Data data) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff202b39),

          title: const Text(
            'Delete User',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          content: Text(
            'Are you sure you want to delete '
            '${data.fullName ?? 'this user'}?',
            style: const TextStyle(color: Color(0xff8994a2), fontSize: 11),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xff8994a2)),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                if (data.id == null || data.id!.isEmpty) {
                  _showError('User ID is missing');
                  return;
                }

                try {
                  await _userApiService.deleteUser(data.id!);

                  await _loadUsers();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                } catch (e) {
                  if (!mounted) return;

                  _showError('Failed to delete user: $e');
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
}
