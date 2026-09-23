import 'package:flutter/material.dart';

import '../../models/assetTypeCRUDModel.dart';
import '../../services/CRUDServices/assetTypeCRUDService.dart';

class AssetTypeCRUDUpdate extends StatefulWidget {
  final AssetType assetType;

  const AssetTypeCRUDUpdate({super.key, required this.assetType});

  @override
  State<AssetTypeCRUDUpdate> createState() => _AssetTypeCRUDUpdateState();
}

class _AssetTypeCRUDUpdateState extends State<AssetTypeCRUDUpdate> {
  final AssetTypeApiService _assetTypeApiService = AssetTypeApiService();

  late TextEditingController codeController;
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;

  late bool isCritical;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    codeController = TextEditingController(
      text: widget.assetType.assetTypeCode,
    );

    nameController = TextEditingController(
      text: widget.assetType.assetTypeName,
    );

    categoryController = TextEditingController(text: widget.assetType.category);

    descriptionController = TextEditingController(
      text: widget.assetType.description,
    );

    isCritical = widget.assetType.isCritical;
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateAssetType() async {
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

    setState(() {
      isUpdating = true;
    });

    try {
      await _assetTypeApiService.updateAssetType(widget.assetType.id, {
        'asset_type_code': code,
        'asset_type_name': name,
        'category': category,
        'description': description,
        'is_critical': isCritical,
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });

      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      child: Container(
        width: 650,
        decoration: BoxDecoration(
          color: const Color(0xff202b39),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                          'Edit Asset Type',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Update asset type configuration',
                          style: TextStyle(
                            color: Color(0xff8994a2),
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
                      color: Color(0xff8994a2),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.white.withOpacity(0.07)),

            // FORM
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 10),
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

                  // CRITICAL
                  Container(
                    height: 52,
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
                          Icons.warning_amber_outlined,
                          size: 18,
                          color: Color(0xff8994a2),
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: Text(
                            'Is Critical',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),

                        Switch(
                          value: isCritical,
                          onChanged: isUpdating
                              ? null
                              : (value) {
                                  setState(() {
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

            // FOOTER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 15),
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
                      style: TextStyle(color: Color(0xff8994a2)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    onPressed: isUpdating ? null : _updateAssetType,

                    icon: isUpdating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 16),

                    label: Text(
                      isUpdating ? 'Updating...' : 'Update Asset Type',
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff078df5),
                      foregroundColor: Colors.white,
                      elevation: 0,
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
}
