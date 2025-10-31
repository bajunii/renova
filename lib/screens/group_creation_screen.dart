import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/group_service.dart';
import '../utils/app_colors.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _groupDetailsController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();

  List<File> _selectedDocuments = [];
  final List<String> _selectedFocusAreas = [];
  int _maxMembers = 20;
  bool _isLoading = false;

  final List<String> _focusAreaOptions = [
    'Plastic Recycling',
    'Paper & Cardboard',
    'Electronic Waste',
    'Organic Waste',
    'Metal Recycling',
    'Glass Recycling',
    'Textile Recycling',
    'Battery Disposal',
    'Hazardous Waste',
    'Community Education',
    'Environmental Awareness',
    'Clean Energy',
  ];

  @override
  void dispose() {
    _groupNameController.dispose();
    _maxMembers = 20;
    _groupDetailsController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedDocuments = result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking files: $e');
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDocuments.isEmpty) {
      _showErrorSnackBar('Please upload at least one verification document');
      return;
    }
    if (_selectedFocusAreas.isEmpty) {
      _showErrorSnackBar('Please select at least one focus area');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, String> socialMedia = {};
      if (_facebookController.text.isNotEmpty) {
        socialMedia['facebook'] = _facebookController.text;
      }
      if (_twitterController.text.isNotEmpty) {
        socialMedia['twitter'] = _twitterController.text;
      }
      if (_instagramController.text.isNotEmpty) {
        socialMedia['instagram'] = _instagramController.text;
      }

      final groupId = await GroupService.createGroup(
        groupName: _groupNameController.text,
        groupDetails: _groupDetailsController.text,
        documents: _selectedDocuments,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        contactNumber: _contactController.text.isNotEmpty
            ? _contactController.text
            : null,
        website: _websiteController.text.isNotEmpty
            ? _websiteController.text
            : null,
        socialMedia: socialMedia,
        focusAreas: _selectedFocusAreas,
        maxMembers: _maxMembers,
      );

      if (mounted) {
        _showSuccessDialog(groupId);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to create group: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String groupId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              const SizedBox(width: 8),
              const Text('Group Created!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Document upload temporarily removed
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your group "${_groupNameController.text}" has been created successfully!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Steps:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Your group is pending admin approval'),
                    const Text('• Documents are under review'),
                    const Text('• You\'ll be notified once approved'),
                    const Text('• Check your profile for status updates'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Your Group',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.group_add, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Group Registration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Create your environmental group and start making a difference',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              _buildTextField(
                controller: _groupNameController,
                label: 'Group Name',
                hint: 'e.g., Green Warriors Community',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Group name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Group name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _groupDetailsController,
                label: 'Group Description',
                hint: 'Describe your group\'s mission and activities...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Group description is required';
                  }
                  if (value.trim().length < 50) {
                    return 'Description must be at least 50 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Contact Information
              _buildSectionTitle('Contact Information'),
              _buildTextField(
                controller: _locationController,
                label: 'Location (Optional)',
                hint: 'City, State/Province, Country',
              ),

              _buildTextField(
                controller: _contactController,
                label: 'Contact Number (Optional)',
                hint: '+1234567890',
                keyboardType: TextInputType.phone,
              ),

              _buildTextField(
                controller: _websiteController,
                label: 'Website (Optional)',
                hint: 'https://yourgroup.org',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 24),

              // Social Media
              _buildSectionTitle('Social Media (Optional)'),
              _buildTextField(
                controller: _facebookController,
                label: 'Facebook',
                hint: 'facebook.com/yourgroup',
              ),

              _buildTextField(
                controller: _twitterController,
                label: 'Twitter/X',
                hint: '@yourgroup',
              ),

              _buildTextField(
                controller: _instagramController,
                label: 'Instagram',
                hint: '@yourgroup',
              ),

              const SizedBox(height: 24),

              // Focus Areas
              _buildSectionTitle('Focus Areas'),
              Text(
                'Select the environmental areas your group focuses on:',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _focusAreaOptions.map((area) {
                  final isSelected = _selectedFocusAreas.contains(area);
                  return FilterChip(
                    label: Text(area),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFocusAreas.add(area);
                        } else {
                          _selectedFocusAreas.remove(area);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Max Members
              _buildSectionTitle('Group Capacity'),
              Text(
                'Maximum number of members: $_maxMembers',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Slider(
                value: _maxMembers.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _maxMembers = value.round();
                  });
                },
              ),

              const SizedBox(height: 24),

              // Document Upload
              _buildSectionTitle('Verification Documents'),
              Text(
                'Upload documents to verify your group (registration certificates, permits, etc.):',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _pickDocuments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Choose Documents',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported formats: PDF, DOC, DOCX, JPG, PNG',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (_selectedDocuments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Documents (${_selectedDocuments.length}):',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._selectedDocuments.map(
                        (file) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  file.path.split('/').last,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Group',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'By creating a group, you agree that all information provided is accurate and that your group will comply with our community guidelines. Your application will be reviewed by our admin team.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
