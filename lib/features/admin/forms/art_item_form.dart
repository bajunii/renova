import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/colors/colors.dart';
import '../pages/market_place.dart';
import '../service/market_service.dart';
import '../../model/market_model.dart';

class ArtItemForm extends StatefulWidget {
  const ArtItemForm({super.key});

  @override
  State<ArtItemForm> createState() => _ArtItemFormState();
}

class _ArtItemFormState extends State<ArtItemForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _artistController = TextEditingController();
  final _tagController = TextEditingController();

  final List<String> _tags = [];
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final marketService = MarketService();

      // Create model instance
      final artItem = ArtitemModel(
        id: '',
        title: _titleController.text.trim(),
        imageUrl: null,
        category: _categoryController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        description: _descriptionController.text.trim(),
        artist: _artistController.text.trim(),
        createdAt: DateTime.now(),
        tags: _tags,
      );

      // Use MarketService
      await marketService.createArtItem(artItem, imageFile: _imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Art item uploaded successfully!')),
      );

      // Reset form
      setState(() {
        _isLoading = false;
        _titleController.clear();
        _categoryController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _artistController.clear();
        _tags.clear();
        _imageFile = null;
      });

      // Redirect to marketplace
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MarketPlace()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Art Item Form',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(labelText: 'Artist'),
                ),
                const SizedBox(height: 20),

                // 🔹 Tags input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Add tag',
                          hintText: 'e.g., abstract, painting',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                      ),
                      onPressed: _addTag,
                    ),
                  ],
                ),

                Wrap(
                  spacing: 8,
                  children: _tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeTag(tag),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 24),

                // 🔹 Image upload section (optional)
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _imageFile == null
                            ? Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Text('No image selected'),
                                ),
                              )
                            : Image.file(
                                _imageFile!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select Image (Optional)'),
                        ),
                      ],
                    ),
                  ),
                ),

                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Create Art Item',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
