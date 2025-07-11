import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/storage_service.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/confirmation_delete_dialog.dart';

class UserEditScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserEditScreen({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _selectedRole;
  late TextEditingController _departmentController;

  bool _isLoading = false;
  String? _profileImageUrl;
  File? _selectedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  // Store initial values to detect changes
  late String _initialName;
  late String _initialEmail;
  late String _initialRole;
  late String _initialDepartment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData['displayName'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _selectedRole = widget.userData['role'] ?? 'Diner';
    _departmentController = TextEditingController(
      text: widget.userData['department'] ?? '',
    );
    _profileImageUrl = widget.userData['profileImageUrl'];

    // Store initial values
    _initialName = widget.userData['displayName'] ?? '';
    _initialEmail = widget.userData['email'] ?? '';
    _initialRole = widget.userData['role'] ?? 'Diner';
    _initialDepartment = widget.userData['department'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileImage(),
                      SizedBox(height: 24.h),
                      _buildFormFields(),
                      SizedBox(height: 24.h),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.fWhite,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fTextH1.withValues(alpha: 0.05),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.fTextH1,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Edit User',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.fNameBoxPink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.fRedBright.withValues(alpha: 0.2),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ],
              image: _getImageProvider(),
            ),
            child: _getImageProvider() == null
                ? Center(
                    child: _selectedImageFile == null
                        ? Icon(
                            Icons.camera_alt,
                            color: AppColors.fRedBright,
                            size: 20.sp,
                          )
                        : null,
                  )
                : Stack(
                    children: [
                      Positioned(
                        right: 2.w,
                        bottom: 2.h,
                        child: Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: AppColors.fWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.fTextH1.withValues(alpha: 0.1),
                                blurRadius: 3.r,
                                offset: Offset(0, 1.h),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            color: AppColors.fTextH1,
                            size: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tap to edit',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.fIconAndLabelText,
            fontFamily: 'Mulish',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  DecorationImage? _getImageProvider() {
    if (_selectedImageFile != null) {
      return DecorationImage(
        image: FileImage(_selectedImageFile!),
        fit: BoxFit.cover,
      );
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(_profileImageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildFormFields() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.fTextH1.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.fTextH1,
              fontFamily: 'Mulish',
            ),
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _nameController,
            hint: 'Display Name :',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a display name';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            controller: _emailController,
            hint: 'Email :',
            icon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            controller: _departmentController,
            hint: 'Department :',
            icon: Icons.business_outlined,
            readOnly: true,
            onTap: () => _showDepartmentPicker(context),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please select a department';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            controller: TextEditingController(text: _selectedRole),
            hint: 'Account Type :',
            icon: Icons.admin_panel_settings_outlined,
            readOnly: true,
            onTap: () => _showRolePicker(context),
            validator: (value) {
              if (_selectedRole.isEmpty) {
                return 'Please select a role';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.fTextH1.withValues(alpha: 0.05),
                blurRadius: 4.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            autovalidateMode: AutovalidateMode.disabled,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Mulish',
              color: AppColors.fTextH1,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Icon(
                  icon,
                  color: AppColors.fIconAndLabelText,
                  size: 20.sp,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              filled: true,
              fillColor: AppColors.fWhite,
              errorStyle: const TextStyle(
                height: 0,
                fontSize: 0,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        // Custom error message outside the text field
        Builder(
          builder: (context) {
            if (validator != null) {
              final errorText = validator(controller.text);
              if (errorText != null) {
                return Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 4.h),
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: AppColors.fRedBright,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Mulish',
                    ),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showDepartmentPicker(BuildContext context) {
    final departmentOptions = ["Software", "Hardware", "Operations"];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Department',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: AppColors.fTextH1,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ...departmentOptions.map((dept) => ListTile(
                    title: Text(
                      dept,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Mulish',
                        color: AppColors.fTextH1,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _departmentController.text = dept;
                      });
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showRolePicker(BuildContext context) {
    final roleOptions = ['Admin', 'Planner', 'Diner'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Role',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: AppColors.fTextH1,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ...roleOptions.map((roleOption) => ListTile(
                    title: Text(
                      roleOption,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Mulish',
                        color: AppColors.fTextH1,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedRole = roleOption;
                      });
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save and Cancel buttons (side by side)
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Cancel',
                AppColors.fTextH1,
                AppColors.fWhite,
                Icons.close,
                _handleCancel,
                hasBorder: true,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionButton(
                'Save Changes',
                AppColors.fWhite,
                AppColors.saveGreen,
                Icons.check,
                _handleSaveChanges,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Delete button (full width)
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            'Delete User',
            AppColors.fWhite,
            AppColors.fRedBright,
            Icons.delete_outline,
            () => _showDeleteUserDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    Color textColor,
    Color backgroundColor,
    IconData icon,
    VoidCallback onTap, {
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: hasBorder
              ? Border.all(
                  color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
                  width: 1.5,
                )
              : null,
          boxShadow: hasBorder
              ? [
                  BoxShadow(
                    color: AppColors.fTextH1.withValues(alpha: 0.05),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: _isLoading && text == 'Save Changes'
            ? Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: textColor,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.fRedBright,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _profileImageUrl;

      // Upload new image if selected
      if (_selectedImageFile != null) {
        imageUrl = await StorageService.uploadProfileImage(
          widget.userId,
          _selectedImageFile!,
        );
      }

      // Update user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'department': _departmentController.text.trim(),
        'role': _selectedRole,
        if (imageUrl != null) 'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('User updated successfully'),
              ],
            ),
            backgroundColor: AppColors.saveGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        Navigator.pop(
            context, true); // Return true to indicate changes were made
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('Error updating user: $e'),
              ],
            ),
            backgroundColor: AppColors.fRedBright,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDeleteDialog(
          title: 'Delete User',
          message: 'Are you sure you want to delete',
          itemName: widget.userData['displayName'] ??
              widget.userData['name'] ??
              'this user',
          onDelete: () {
            _deleteUser();
          },
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Delete user from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .delete();

      // Note: Profile image will be cleaned up by Firebase Storage rules or separate cleanup job

      if (context.mounted) {
        Navigator.pop(context); // Close edit screen
        Navigator.pop(context); // Go back to users list

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('User deleted successfully'),
              ],
            ),
            backgroundColor: AppColors.fRedBright,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('Error deleting user: $e'),
              ],
            ),
            backgroundColor: AppColors.fRedBright,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSaveChanges() {
    if (!_hasChanges()) {
      // No changes detected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: AppColors.fWhite),
              SizedBox(width: 8.w),
              Text('No changes detected'),
            ],
          ),
          backgroundColor: AppColors.fIconAndLabelText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return;
    }

    // Show confirmation dialog for changes
    _showSaveConfirmationDialog();
  }

  void _handleCancel() {
    if (!_hasChanges()) {
      // No changes, just go back
      Navigator.pop(context);
      return;
    }

    // Show confirmation dialog for unsaved changes
    _showCancelConfirmationDialog();
  }

  Future<void> _showSaveConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.fTransparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fTextH1.withValues(alpha: 0.1),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.saveGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.save_outlined,
                    color: AppColors.saveGreen,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fTextH1,
                    fontFamily: 'Mulish',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  'Are you sure you want to save these changes to the user profile?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.fIconAndLabelText,
                    fontFamily: 'Mulish',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.fIconAndLabelText
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fIconAndLabelText,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Save Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.saveGreen,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.saveGreen.withValues(alpha: 0.3),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fWhite,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      _saveChanges();
    }
  }

  Future<void> _showCancelConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.fTransparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fTextH1.withValues(alpha: 0.1),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.fYellow.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_outlined,
                    color: AppColors.fYellow,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Unsaved Changes',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fTextH1,
                    fontFamily: 'Mulish',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  'You have unsaved changes. Are you sure you want to discard them?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.fIconAndLabelText,
                    fontFamily: 'Mulish',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),

                // Buttons
                Row(
                  children: [
                    // Keep Editing Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.fIconAndLabelText
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'Keep Editing',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fIconAndLabelText,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Discard Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.fRedBright,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.fRedBright.withValues(alpha: 0.3),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Discard',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fWhite,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      Navigator.pop(context);
    }
  }

  bool _hasChanges() {
    return _nameController.text.trim() != _initialName ||
        _emailController.text.trim() != _initialEmail ||
        _selectedRole != _initialRole ||
        _departmentController.text.trim() != _initialDepartment ||
        _selectedImageFile != null; // New image selected
  }
}
