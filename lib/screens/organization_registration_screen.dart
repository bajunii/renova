import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/group.dart';
import '../services/group_auth_service.dart';
import '../utils/app_colors.dart';
import 'dashboards/group_dashboard.dart';

class OrganizationRegistrationScreen extends StatefulWidget {
  final VoidCallback? onRegistrationComplete;
  final bool isEmbedded;

  const OrganizationRegistrationScreen({
    super.key,
    this.onRegistrationComplete,
    this.isEmbedded = false,
  });

  @override
  State<OrganizationRegistrationScreen> createState() =>
      _OrganizationRegistrationScreenState();
}

class _OrganizationRegistrationScreenState
    extends State<OrganizationRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organizationNameController = TextEditingController();
  final _organizationEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _websiteController = TextEditingController();

  final GroupAuthService _groupAuthService = GroupAuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final List<GroupMember> _members = [];
  List<File> _documents = [];
  List<String> _documentNames = [];
  bool _isUploadingDocuments = false;
  final List<String> _focusAreas = [];
  final Map<String, String> _socialMedia = {};

  final List<String> _availableFocusAreas = [
    'Plastic Recycling',
    'Paper Recycling',
    'Electronic Waste',
    'Organic Waste',
    'Metal Recycling',
    'Glass Recycling',
    'Textile Recycling',
    'Hazardous Waste',
    'Community Education',
    'Environmental Advocacy',
  ];

  // Public method to trigger registration from parent widget
  Future<bool> registerOrganization() async {
    return await _handleRegistration();
  }

  // Getter to check if form is valid
  bool get isFormValid =>
      _formKey.currentState?.validate() == true && _validateMembers();

  @override
  void initState() {
    super.initState();
    // Initialize with one leader member
    _members.add(
      GroupMember(
        userId: '', // Will be set after auth
        name: '',
        email: '',
        role: MemberRole.leader,
        joinedAt: DateTime.now(),
        isActive: true,
      ),
    );
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _organizationEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _documents = result.paths.map((path) => File(path!)).toList();
          _documentNames = result.files.map((file) => file.name).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_documents.length} document(s) selected'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking documents: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> _uploadDocuments(String organizationId) async {
    if (_documents.isEmpty) return [];

    setState(() {
      _isUploadingDocuments = true;
    });

    List<String> documentUrls = [];

    try {
      for (int i = 0; i < _documents.length; i++) {
        final file = _documents[i];
        final fileName = _documentNames[i];

        // Create a unique file name
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_$fileName';

        // Create storage reference
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('organization_documents')
            .child(organizationId)
            .child(uniqueFileName);

        // Upload file
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        documentUrls.add(downloadUrl);

        print('✅ Document uploaded: $fileName -> $downloadUrl');
      }

      setState(() {
        _isUploadingDocuments = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${documentUrls.length} document(s) uploaded successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      return documentUrls;
    } catch (e) {
      setState(() {
        _isUploadingDocuments = false;
      });

      print('❌ Error uploading documents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading documents: $e'),
          backgroundColor: Colors.red,
        ),
      );

      throw Exception('Failed to upload documents: $e');
    }
  }

  void _addMember() {
    setState(() {
      _members.add(
        GroupMember(
          userId: '', // Will be set later
          name: '',
          email: '',
          role: MemberRole.member,
          joinedAt: DateTime.now(),
          isActive: true,
        ),
      );
    });
  }

  void _removeMember(int index) {
    if (_members.length > 1) {
      // Keep at least one member
      setState(() {
        _members.removeAt(index);
      });
    }
  }

  void _updateMember(
    int index, {
    String? name,
    String? email,
    MemberRole? role,
  }) {
    setState(() {
      final member = _members[index];
      _members[index] = GroupMember(
        userId: member.userId,
        name: name ?? member.name,
        email: email ?? member.email,
        role: role ?? member.role,
        joinedAt: member.joinedAt,
        isActive: member.isActive,
      );
    });
  }

  Future<bool> _handleRegistration() async {
    if (_formKey.currentState!.validate() && _validateMembers()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the leader member for registration
        final leader = _members.firstWhere((m) => m.role == MemberRole.leader);

        // Register organization
        final result = await _groupAuthService.registerGroupOrganization(
          organizationEmail: _organizationEmailController.text,
          password: _passwordController.text,
          organizationName: _organizationNameController.text,
          leaderName: leader.name,
          leaderEmail: leader.email,
        );

        if (result != null && mounted) {
          // Upload documents if any
          List<String> documentUrls = [];
          if (_documents.isNotEmpty) {
            try {
              documentUrls = await _uploadDocuments(result.user!.uid);
            } catch (e) {
              // Show warning but continue with registration
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Documents upload failed: $e'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }

          // Create the group with all members and documents
          final groupId = await _createGroupWithMembers(
            result.user!.uid,
            documentUrls,
          );

          // Link group to organization
          await _groupAuthService.linkGroupToOrganization(groupId);

          // Set current member to leader
          await _groupAuthService.setCurrentMember(leader.email);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Organization registered successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Call callback if provided or navigate to dashboard
            if (widget.onRegistrationComplete != null) {
              widget.onRegistrationComplete!();
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GroupDashboard()),
              );
            }
          }
          return true;
        }
        return false;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
    return false;
  }

  Future<String> _createGroupWithMembers(
    String organizationUserId,
    List<String> documentUrls,
  ) async {
    try {
      // Update member user IDs with email as placeholder
      final updatedMembers = _members
          .map(
            (member) => GroupMember(
              userId: member.email, // Use email as user ID for now
              name: member.name,
              email: member.email,
              role: member.role,
              joinedAt: member.joinedAt,
              isActive: member.isActive,
            ),
          )
          .toList();

      // Create group document in Firestore
      final groupDoc = FirebaseFirestore.instance.collection('groups').doc();

      final group = Group(
        id: groupDoc.id,
        groupName: _organizationNameController.text,
        groupDetails: _descriptionController.text,
        documentUrls: documentUrls, // Use uploaded document URLs
        status: GroupStatus.pending,
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
        members: updatedMembers,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        contactNumber: _contactController.text.isEmpty
            ? null
            : _contactController.text,
        website: _websiteController.text.isEmpty
            ? null
            : _websiteController.text,
        socialMedia: _socialMedia,
        focusAreas: _focusAreas,
        maxMembers: 100,
      );

      // Save group to Firestore
      await groupDoc.set(group.toMap());

      print(
        '✅ Group created successfully: ${group.groupName} with ID: ${groupDoc.id}',
      );
      print('📄 Documents uploaded: ${documentUrls.length} files');
      return groupDoc.id;
    } catch (e) {
      print('❌ Error creating group: $e');
      throw Exception('Failed to create group: $e');
    }
  }

  bool _validateMembers() {
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one member is required'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check if there's at least one leader
    if (!_members.any((m) => m.role == MemberRole.leader)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one leader is required'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check if all members have names and emails
    for (int i = 0; i < _members.length; i++) {
      if (_members[i].name.isEmpty || _members[i].email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all details for member ${i + 1}'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - only show if not embedded
            if (!widget.isEmbedded) ...[
              Card(
                color: AppColors.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.business, size: 48, color: AppColors.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Register Your Organization',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create an organization account that all members can access',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Organization Details
            _buildSectionTitle('Organization Details'),
            const SizedBox(height: 16),

            TextFormField(
              controller: _organizationNameController,
              decoration: const InputDecoration(
                labelText: 'Organization Name *',
                hintText: 'Enter your organization name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Organization name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _organizationEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Organization Email *',
                hintText: 'Enter organization email address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Organization email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      hintText: 'Enter password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password *',
                      hintText: 'Confirm password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Organization Description *',
                hintText:
                    'Describe your organization\'s mission and activities',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Organization description is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Members Section
            _buildSectionTitle('Organization Members'),
            const SizedBox(height: 16),

            _buildMembersSection(),

            const SizedBox(height: 24),

            // Additional Information
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'City, Country',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      hintText: '+1234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                hintText: 'https://yourorganization.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.web),
              ),
            ),

            const SizedBox(height: 16),

            _buildFocusAreasSection(),

            const SizedBox(height: 24),

            // Documents Section
            _buildSectionTitle('Verification Documents'),
            const SizedBox(height: 16),

            _buildDocumentsSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Register Organization'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: content,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      children: [
        ..._members.asMap().entries.map((entry) {
          int index = entry.key;
          GroupMember member = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getRoleColor(member.role),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Member ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_members.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeMember(index),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: member.name,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              _updateMember(index, name: value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: member.email,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              _updateMember(index, email: value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MemberRole>(
                    value: member.role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: MemberRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(_getRoleDisplayName(role)),
                      );
                    }).toList(),
                    onChanged: (role) {
                      if (role != null) {
                        _updateMember(index, role: role);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: _addMember,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Member'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusAreasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Focus Areas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableFocusAreas.map((area) {
            final isSelected = _focusAreas.contains(area);
            return FilterChip(
              label: Text(area),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _focusAreas.add(area);
                  } else {
                    _focusAreas.remove(area);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload verification documents (Registration Certificate, License, etc.)',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: _isUploadingDocuments ? null : _pickDocuments,
          icon: _isUploadingDocuments
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(
            _isUploadingDocuments ? 'Uploading...' : 'Select Documents',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Supported formats: PDF, DOC, DOCX, JPG, JPEG, PNG',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),

        if (_documents.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_documents.length} document(s) selected',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._documents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  final fileName =
                      _documentNames.isNotEmpty && index < _documentNames.length
                      ? _documentNames[index]
                      : doc.path.split('/').last;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(fileName),
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _documents.removeAt(index);
                              if (index < _documentNames.length) {
                                _documentNames.removeAt(index);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.leader:
        return Colors.purple;
      case MemberRole.chair:
        return Colors.indigo;
      case MemberRole.secretary:
        return Colors.blue;
      case MemberRole.treasurer:
        return Colors.green;
      case MemberRole.member:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.leader:
        return 'Leader';
      case MemberRole.chair:
        return 'Chairperson';
      case MemberRole.secretary:
        return 'Secretary';
      case MemberRole.treasurer:
        return 'Treasurer';
      case MemberRole.member:
        return 'Member';
    }
  }
}
