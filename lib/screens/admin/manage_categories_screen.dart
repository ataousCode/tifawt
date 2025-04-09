// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/success_dialog.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _iconImage;
  bool _isActive = true;
  bool _isEditing = false;
  String? _editingCategoryId;

  @override
  void initState() {
    super.initState();

    // Load categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  // Load categories
  Future<void> _loadCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Load all categories including inactive ones
    categoryProvider.loadCategories(activeOnly: false);
  }

  // Reset form
  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _orderController.text = '0';
      _iconImage = null;
      _isActive = true;
      _isEditing = false;
      _editingCategoryId = null;
    });
  }

  // Set form for editing
  void _editCategory(Category category) {
    setState(() {
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
      _orderController.text = category.order.toString();
      _isActive = category.isActive;
      _isEditing = true;
      _editingCategoryId = category.id;
    });
  }

  // Pick icon image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _iconImage = File(image.path);
      });
    }
  }

  // Save category
  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
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

    try {
      bool success;

      if (_isEditing) {
        // Update existing category
        success = await categoryProvider.updateCategory(
          id: _editingCategoryId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          iconImage: _iconImage,
          order: int.parse(_orderController.text),
          isActive: _isActive,
        );
      } else {
        // Add new category
        success = await categoryProvider.addCategory(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          iconImage: _iconImage,
          order: int.parse(_orderController.text),
        );
      }

      if (success && mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => SuccessDialog(
                title: _isEditing ? 'Category Updated' : 'Category Added',
                message:
                    _isEditing
                        ? 'The category has been successfully updated.'
                        : 'The category has been successfully added.',
                onDismiss: () {
                  _resetForm();
                },
              ),
        );
      }
    } catch (e) {
      Helpers.showErrorSnackBar(
        context,
        'Failed to save category: ${e.toString()}',
      );
    }
  }

  // Delete category
  Future<void> _deleteCategory(Category category) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
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

    Helpers.showConfirmationDialog(
      context: context,
      title: 'Delete Category',
      message:
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
      onConfirm: () async {
        try {
          final success = await categoryProvider.deleteCategory(category.id);

          if (success && mounted) {
            Helpers.showSuccessSnackBar(
              context,
              'Category deleted successfully',
            );

            // Reset form if we were editing this category
            if (_isEditing && _editingCategoryId == category.id) {
              _resetForm();
            }
          }
        } catch (e) {
          Helpers.showErrorSnackBar(
            context,
            'Failed to delete category: ${e.toString()}',
          );
        }
      },
      confirmButtonText: 'Delete',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (!authProvider.isAuthenticated || !authProvider.isAdmin) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Manage Categories'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              const Text(
                'Admin access required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: ThemeConstants.smallPadding),
              const Text(
                'You need to be an admin to access this page',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Manage Categories',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
          ),
        ],
      ),
      body:
          categoryProvider.loading
              ? const LoadingIndicator(message: 'Loading categories...')
              : SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.largePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category form
                    Card(
                      elevation: ThemeConstants.smallElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.mediumRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          ThemeConstants.largePadding,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditing
                                    ? 'Edit Category'
                                    : 'Add New Category',
                                style: ThemeConstants.titleStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: ThemeConstants.mediumPadding,
                              ),

                              // Icon picker
                              Center(
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(
                                        ThemeConstants.mediumRadius,
                                      ),
                                      image:
                                          _iconImage != null
                                              ? DecorationImage(
                                                image: FileImage(_iconImage!),
                                                fit: BoxFit.cover,
                                              )
                                              : _isEditing &&
                                                  _editingCategoryId != null
                                              ? categoryProvider.categories
                                                          .firstWhere(
                                                            (c) =>
                                                                c.id ==
                                                                _editingCategoryId,
                                                            orElse:
                                                                () => Category(
                                                                  id: '',
                                                                  name: '',
                                                                ),
                                                          )
                                                          .iconUrl !=
                                                      null
                                                  ? DecorationImage(
                                                    image: CachedNetworkImageProvider(
                                                      categoryProvider
                                                          .categories
                                                          .firstWhere(
                                                            (c) =>
                                                                c.id ==
                                                                _editingCategoryId,
                                                            orElse:
                                                                () => Category(
                                                                  id: '',
                                                                  name: '',
                                                                ),
                                                          )
                                                          .iconUrl!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : null
                                              : null,
                                    ),
                                    child:
                                        _iconImage == null &&
                                                (!_isEditing ||
                                                    categoryProvider.categories
                                                            .firstWhere(
                                                              (c) =>
                                                                  c.id ==
                                                                  _editingCategoryId,
                                                              orElse:
                                                                  () =>
                                                                      Category(
                                                                        id: '',
                                                                        name:
                                                                            '',
                                                                      ),
                                                            )
                                                            .iconUrl ==
                                                        null)
                                            ? const Icon(
                                              Icons.add_photo_alternate,
                                              size: 40,
                                              color: Colors.grey,
                                            )
                                            : null,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: ThemeConstants.smallPadding,
                              ),

                              Center(
                                child: TextButton.icon(
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Select Icon'),
                                  onPressed: _pickImage,
                                ),
                              ),

                              const SizedBox(
                                height: ThemeConstants.mediumPadding,
                              ),

                              // Name field
                              const Text(
                                'Category Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: ThemeConstants.smallPadding,
                              ),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter category name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a category name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(
                                height: ThemeConstants.mediumPadding,
                              ),

                              // Description field
                              const Text(
                                'Description (Optional)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: ThemeConstants.smallPadding,
                              ),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter category description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),

                              const SizedBox(
                                height: ThemeConstants.mediumPadding,
                              ),

                              // Order field
                              const Text(
                                'Display Order',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: ThemeConstants.smallPadding,
                              ),
                              TextFormField(
                                controller: _orderController,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Enter display order (0, 1, 2, ...)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a display order';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(
                                height: ThemeConstants.mediumPadding,
                              ),

                              // Active status (only for editing)
                              if (_isEditing) ...[
                                Row(
                                  children: [
                                    const Text(
                                      'Active',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: ThemeConstants.mediumPadding,
                                    ),
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

                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),
                              ],

                              // Action buttons
                              Row(
                                children: [
                                  if (_isEditing) ...[
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _resetForm,
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: ThemeConstants.mediumPadding,
                                    ),
                                  ],
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saveCategory,
                                      child: Text(
                                        _isEditing ? 'Update' : 'Add Category',
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

                    const SizedBox(height: ThemeConstants.extraLargePadding),

                    // Categories list
                    Text(
                      'All Categories',
                      style: ThemeConstants.titleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: ThemeConstants.mediumPadding),

                    categoryProvider.categories.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              ThemeConstants.largePadding,
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),
                                const Text(
                                  'No categories yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: ThemeConstants.smallPadding,
                                ),
                                const Text(
                                  'Add a new category using the form above',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = categoryProvider.categories[index];

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: ThemeConstants.mediumPadding,
                              ),
                              elevation: ThemeConstants.smallElevation,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ThemeConstants.mediumRadius,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: ThemeConstants.primaryLightColor,
                                    borderRadius: BorderRadius.circular(
                                      ThemeConstants.smallRadius,
                                    ),
                                    image:
                                        category.iconUrl != null
                                            ? DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                category.iconUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                            : null,
                                  ),
                                  child:
                                      category.iconUrl == null
                                          ? const Icon(
                                            Icons.category,
                                            color: ThemeConstants.primaryColor,
                                          )
                                          : null,
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!category.isActive) ...[
                                      const SizedBox(
                                        width: ThemeConstants.smallPadding,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'Inactive',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle:
                                    category.description != null &&
                                            category.description!.isNotEmpty
                                        ? Text(
                                          category.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                        : Text(
                                          'Order: ${category.order}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: ThemeConstants.primaryColor,
                                      ),
                                      onPressed: () => _editCategory(category),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _deleteCategory(category),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
    );
  }
}
