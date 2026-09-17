import 'package:flutter/material.dart';

import '../../models/orgCRUDModel.dart';
import '../../services/CRUDServices/orgCRUDAPIService.dart';

class OrgCRUDUpdate extends StatefulWidget {
  final OrgData organization;
  final VoidCallback? onUpdated;

  const OrgCRUDUpdate({super.key, required this.organization, this.onUpdated});

  @override
  State<OrgCRUDUpdate> createState() => _OrgCRUDUpdateState();
}

class _OrgCRUDUpdateState extends State<OrgCRUDUpdate> {
  final OrgApiService _orgApiService = OrgApiService();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  late final TextEditingController orgNameController;
  late final TextEditingController descriptionController;
  late final TextEditingController contactPersonController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  String selectedStatus = 'active';

  bool isUpdating = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    orgNameController = TextEditingController(
      text: widget.organization.orgName ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.organization.description ?? '',
    );

    contactPersonController = TextEditingController(
      text: widget.organization.contactPerson ?? '',
    );

    emailController = TextEditingController(
      text: widget.organization.email ?? '',
    );

    phoneController = TextEditingController(
      text: widget.organization.phone ?? '',
    );

    addressController = TextEditingController(
      text: widget.organization.address ?? '',
    );

    // IMPORTANT:
    // Dropdown only accepts exactly "active" or "inactive".
    final String status =
        widget.organization.status?.trim().toLowerCase() ?? '';

    selectedStatus = status == 'inactive' ? 'inactive' : 'active';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    orgNameController.dispose();
    descriptionController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();

    super.dispose();
  }

  // ============================================================
  // UPDATE ORGANIZATION
  // ============================================================

  Future<void> _updateOrganization() async {
    final String? organizationId = widget.organization.id;

    if (organizationId == null || organizationId.isEmpty) {
      _showSnackBar('Organization ID is missing', isError: true);
      return;
    }

    if (orgNameController.text.trim().isEmpty) {
      _showSnackBar('Organization name is required', isError: true);
      return;
    }

    setState(() {
      isUpdating = true;
    });

    final Map<String, dynamic> updateData = {
      'org_name': orgNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'contact_person': contactPersonController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'status': selectedStatus,
    };

    try {
      await _orgApiService.updateOrganization(organizationId, updateData);

      if (!mounted) return;

      _showSnackBar('Organization updated successfully');

      widget.onUpdated?.call();

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });

      _showSnackBar('Failed to update organization: $e', isError: true);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      child: Container(
        width: 812,
        constraints: const BoxConstraints(maxWidth: 812, maxHeight: 820),
        decoration: BoxDecoration(
          color: const Color(0xff202b39),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 28, 26, 24),
              child: Row(
                children: [
                  // ICON
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xff078df5).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business_outlined,
                      color: Color(0xff078df5),
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 18),

                  // TITLE
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Organization',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Update organization details and contact information',
                          style: TextStyle(
                            color: Color(0xff8994a2),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CLOSE
                  IconButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xff8994a2),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.white.withOpacity(0.06)),

            // ==================================================
            // FORM
            // ==================================================
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 26, 30, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------
                    // ORGANIZATION INFORMATION HEADER
                    // ------------------------------------------
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xff8994a2).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.business_outlined,
                            color: Color(0xff8994a2),
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organization Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Update the basic organization details',
                              style: TextStyle(
                                color: Color(0xff8994a2),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------
                    // ORGANIZATION NAME
                    // ------------------------------------------
                    _buildInputField(
                      controller: orgNameController,
                      hintText: 'Organization Name',
                      icon: Icons.business_outlined,
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // DESCRIPTION
                    // ------------------------------------------
                    _buildInputField(
                      controller: descriptionController,
                      hintText: 'Description',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // CONTACT + EMAIL
                    // ------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: contactPersonController,
                            hintText: 'Contact Person',
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _buildInputField(
                            controller: emailController,
                            hintText: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // PHONE + ADDRESS
                    // ------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: phoneController,
                            hintText: 'Phone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _buildInputField(
                            controller: addressController,
                            hintText: 'Address',
                            icon: Icons.location_on_outlined,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // STATUS
                    // ------------------------------------------
                    _buildStatusDropdown(),
                  ],
                ),
              ),
            ),

            // ==================================================
            // FOOTER
            // ==================================================
            Divider(height: 1, color: Colors.white.withOpacity(0.06)),

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 14, 30, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // CANCEL
                  TextButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xff8994a2), fontSize: 13),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // UPDATE
                  ElevatedButton.icon(
                    onPressed: isUpdating ? null : _updateOrganization,
                    icon: isUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.business_outlined, size: 17),
                    label: Text(
                      isUpdating ? 'Updating...' : 'Update Organization',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff078df5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xff078df5,
                      ).withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
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
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !isUpdating,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 13),

        prefixIcon: Icon(icon, color: Color(0xff8994a2), size: 20),

        filled: true,
        fillColor: const Color(0xff141e2a),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
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
    );
  }

  // ============================================================
  // STATUS DROPDOWN
  // ============================================================

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,

      isExpanded: true,

      dropdownColor: const Color(0xff18222e),

      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xff8994a2)),

      style: const TextStyle(color: Colors.white, fontSize: 13),

      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.toggle_on_outlined,
          color: Color(0xff8994a2),
          size: 21,
        ),

        labelText: 'Status',

        labelStyle: const TextStyle(color: Color(0xff8994a2), fontSize: 11),

        filled: true,
        fillColor: const Color(0xff141e2a),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff078df5)),
        ),
      ),

      items: const [
        DropdownMenuItem<String>(value: 'active', child: Text('Active')),
        DropdownMenuItem<String>(value: 'inactive', child: Text('Inactive')),
      ],

      onChanged: isUpdating
          ? null
          : (String? value) {
              if (value == null) return;

              setState(() {
                selectedStatus = value;
              });
            },
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
