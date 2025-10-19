import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';

class ArtItemForm extends StatefulWidget {
  const ArtItemForm({super.key});

  @override
  State<ArtItemForm> createState() => _ArtItemFormState();
}

class _ArtItemFormState extends State<ArtItemForm> {
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

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

  void _submitForm() {
    // if (_formKey.currentState!.validate()) {
    //   final artItem = ArtItem(
    //     // title: _titleController.text,
    //     // description: _descriptionController.text,
    //     tags: _tags.isEmpty ? null : _tags,
    //   );
    //   debugPrint('Created ArtItem: ${artItem.title}, tags: ${artItem.tags}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ArtItem Form',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Price'),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                  ),

                  TextFormField(
                    decoration: InputDecoration(labelText: 'Artist'),
                  ),

                  // Tags input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          // controller: _tagController,
                          decoration: const InputDecoration(
                            labelText: 'Add tag',
                            hintText: 'e.g., abstract, painting',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ],
                  ),

                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(height: 20),
                  Text('Image Upload Placeholder'),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      // Handle form submission
                    },
                    child: Text('Submit'),
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
