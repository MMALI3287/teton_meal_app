import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/app/app_fonts.dart';
import 'package:teton_meal_app/data/services/storage_service.dart';
import 'package:teton_meal_app/features/authentication/presentation/widgets/registration_form_widget.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/standard_back_button.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();

      if (source == ImageSource.camera) {
        await _requestCameraPermission();
      } else {
        await _requestGalleryPermission();
      }

      final XFile? pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });

        await _uploadImageToFirebase();
      }
    } catch (e) {
      print('Image picker error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      return;
    } catch (e) {
      print('Camera permission error: ${e.toString()}');
      throw Exception('Camera permission denied');
    }
  }

  Future<void> _requestGalleryPermission() async {
    try {
      return;
    } catch (e) {
      print('Gallery permission error: ${e.toString()}');
      throw Exception('Gallery permission denied');
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      if (kDebugMode) {
        print('Starting upload process');

        final fileExists = await _selectedImage!.exists();
        final fileSize = fileExists ? await _selectedImage!.length() : 0;
        print('Selected image exists: $fileExists, size: $fileSize bytes');
      }

      final hasStorageAccess = await StorageService.checkStoragePermissions();
      if (!hasStorageAccess) {
        throw Exception(
            'Storage access denied. Please check Firebase Storage rules.');
      }

      final String fileName = 'profile_${const Uuid().v4()}.jpg';

      if (kDebugMode) {
        print('Uploading file: ${_selectedImage!.path} as $fileName');
      }

      final downloadUrl = await StorageService.uploadFile(
        filePath: _selectedImage!.path,
        fileName: fileName,
        contentType: 'image/jpeg',
        folder: 'profile_images',
      );

      if (downloadUrl == null) {
        throw Exception('Upload failed - could not get download URL');
      }

      if (kDebugMode) {
        print('Upload successful. URL: $downloadUrl');
      }

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: ${e.toString()}');

        if (e is FirebaseException) {
          print('Firebase error code: ${e.code}, message: ${e.message}');
        }
      }
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Image Source',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Mulish',
            color: AppColors.fTextH1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.fTextH1),
              title: Text(
                'Take a photo',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Mulish',
                  color: AppColors.fTextH1,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();

                Future.delayed(const Duration(milliseconds: 300), () {
                  _pickImage(ImageSource.camera);
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: AppColors.fTextH1),
              title: Text(
                'Choose from gallery',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Mulish',
                  color: AppColors.fTextH1,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();

                Future.delayed(const Duration(milliseconds: 300), () {
                  _pickImage(ImageSource.gallery);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  StandardBackButton(),
                  SizedBox(width: 16.w),
                  Text(
                    'Create New Account',
                    style: AppFonts.h2,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.h,
                          decoration: BoxDecoration(
                            color: AppColors.fWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.fTextH1.withValues(alpha: 0.05),
                                blurRadius: 4.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.fIconAndLabelText,
                                  size: 24.sp,
                                )
                              : null,
                        ),
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.fTextH1.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.fWhite,
                                  strokeWidth: 2.w,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child:
                    RegistrationFormWidget(profileImageUrl: _uploadedImageUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
