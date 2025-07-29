// lib/core/widgets/image_picker_field.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

class ImagePickerField extends StatefulWidget {
  final String? currentImagePath;
  final ValueChanged<String?> onImageSelected;
  final String label;
  final double size;

  const ImagePickerField({
    super.key,
    this.currentImagePath,
    required this.onImageSelected,
    this.label = 'Select Image',
    this.size = 100,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (image != null) {
      widget.onImageSelected(image.path);
    }
  }

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (image != null) {
      widget.onImageSelected(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(
                color: AppColors.neutral300,
                width: 2,
              ),
              image: widget.currentImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(widget.currentImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.currentImagePath == null
                ? Icon(
                    Icons.add_a_photo,
                    size: widget.size * 0.4,
                    color: AppColors.neutral400,
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppDimens.spacingS),
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            if (widget.currentImagePath != null) ...[
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onImageSelected(null);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}