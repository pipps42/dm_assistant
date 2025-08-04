// lib/shared/components/inputs/entity_image_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EntityImagePicker extends StatefulWidget {
  final String? initialImagePath;
  final String placeholderText;
  final IconData placeholderIcon;
  final double height;
  final Function(String?) onImageChanged;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;

  const EntityImagePicker({
    super.key,
    this.initialImagePath,
    this.placeholderText = 'Add Image',
    this.placeholderIcon = Icons.add_photo_alternate,
    this.height = 120,
    required this.onImageChanged,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  State<EntityImagePicker> createState() => _EntityImagePickerState();
}

class _EntityImagePickerState extends State<EntityImagePicker> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImagePath;
  }

  @override
  void didUpdateWidget(EntityImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImagePath != oldWidget.initialImagePath) {
      _selectedImagePath = widget.initialImagePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);
    final borderColor = widget.borderColor ?? Colors.grey.shade300;
    final backgroundColor = widget.backgroundColor ?? Colors.grey.shade50;

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: borderRadius,
      ),
      child: _selectedImagePath != null
          ? _buildImagePreview(borderRadius)
          : _buildPlaceholder(borderRadius, backgroundColor),
    );
  }

  Widget _buildImagePreview(BorderRadius borderRadius) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: Image.file(
            File(_selectedImagePath!),
            width: double.infinity,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholder(borderRadius, widget.backgroundColor ?? Colors.grey.shade50),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() => _selectedImagePath = null);
                widget.onImageChanged(null);
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BorderRadius borderRadius, Color backgroundColor) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.placeholderIcon,
              size: 32,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              widget.placeholderText,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        widget.onImageChanged(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
}