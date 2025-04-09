// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/proverb.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/success_dialog.dart';

class AddProverbScreen extends StatefulWidget {
  final String? proverbId;

  const AddProverbScreen({super.key, this.proverbId});

  @override
  State<AddProverbScreen> createState() => _AddProverbScreenState();
}

class _AddProverbScreenState extends State<AddProverbScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _authorController = TextEditingController();
  String? _selectedCategoryId;
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();
  bool _isActive = true;
  bool _isEditing = false;
  bool _isLoading = false;
  Proverb? _proverb;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.proverbId != null;

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Load categories
    categoryProvider.loadCategories();

    // If editing, load proverb data
    if (_isEditing) {
      await _loadProverbData();
    } else {
      // Select first category as default
      if (categoryProvider.categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = categoryProvider.categories.first.id;
        });
      }
    }
  }

  Future<void> _loadProverbData() async {
    setState(() {
      _isLoading = true;
    });

    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );

    try {
      final proverb = await proverbProvider.getProverbById(widget.proverbId!);

      if (proverb != null) {
        setState(() {
          _proverb = proverb;
          _textController.text = proverb.text;
          _authorController.text = proverb.author;
          _selectedCategoryId = proverb.categoryId;
          _isActive = proverb.isActive;
        });
      }
    } catch (e) {
      Helpers.showErrorSnackBar(
        context,
        'Failed to load proverb data: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _backgroundImage = File(image.path);
      });
    }
  }

  Future<void> _saveProverb() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isEditing && _backgroundImage == null) {
      Helpers.showErrorSnackBar(context, 'Please select a background image');
      return;
    }

    if (_selectedCategoryId == null) {
      Helpers.showErrorSnackBar(context, 'Please select a category');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );

    if (!authProvider.isAdmin) {
      Helpers.showErrorSnackBar(
        context,
        'You do not have permission to perform this action',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;

      if (_isEditing) {
        // Update existing proverb
        success = await proverbProvider.updateProverb(
          id: widget.proverbId!,
          text: _textController.text.trim(),
          author: _authorController.text.trim(),
          categoryId: _selectedCategoryId,
          backgroundImage: _backgroundImage,
          isActive: _isActive,
        );
      } else {
        // Add new proverb
        success = await proverbProvider.addProverb(
          text: _textController.text.trim(),
          author: _authorController.text.trim(),
          categoryId: _selectedCategoryId!,
          backgroundImage: _backgroundImage!,
        );
      }

      if (success && mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => SuccessDialog(
                title: _isEditing ? 'Proverb Updated' : 'Proverb Added',
                message:
                    _isEditing
                        ? 'The proverb has been successfully updated.'
                        : 'The proverb has been successfully added to the collection.',
                onDismiss: () {
                  Navigator.of(context).pop();
                },
              ),
        );
      }
    } catch (e) {
      Helpers.showErrorSnackBar(
        context,
        'Failed to save proverb: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: _isEditing ? 'Edit Proverb' : 'Add Proverb'),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Loading...')
              : SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.largePadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image picker
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.mediumRadius,
                              ),
                              image:
                                  _backgroundImage != null
                                      ? DecorationImage(
                                        image: FileImage(_backgroundImage!),
                                        fit: BoxFit.cover,
                                      )
                                      : _proverb != null
                                      ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          _proverb!.backgroundImageUrl,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                _backgroundImage == null && _proverb == null
                                    ? const Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: ThemeConstants.smallPadding),

                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: Text(
                            _backgroundImage != null || _proverb != null
                                ? 'Change Image'
                                : 'Select Image',
                          ),
                          onPressed: _pickImage,
                        ),
                      ),

                      const SizedBox(height: ThemeConstants.largePadding),

                      // Proverb text
                      const Text(
                        'Proverb Text',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: ThemeConstants.smallPadding),
                      TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter the proverb text',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the proverb text';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: ThemeConstants.mediumPadding),

                      // Author
                      const Text(
                        'Author',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: ThemeConstants.smallPadding),
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          hintText: 'Enter the author name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the author name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: ThemeConstants.mediumPadding),

                      // Category
                      const Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: ThemeConstants.smallPadding),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          hintText: 'Select a category',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            categoryProvider.categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: ThemeConstants.mediumPadding),

                      // Active status (only for editing)
                      if (_isEditing) ...[
                        Row(
                          children: [
                            const Text(
                              'Active',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: ThemeConstants.mediumPadding),
                            Switch(
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                              activeColor: ThemeConstants.primaryColor,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: ThemeConstants.largePadding),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProverb,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    _isEditing
                                        ? 'Update Proverb'
                                        : 'Add Proverb',
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
