import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_auth_service.dart';
import '../utils/app_colors.dart';
import 'dashboards/group_dashboard.dart';

class MemberSelectionScreen extends StatefulWidget {
  final Group group;

  const MemberSelectionScreen({super.key, required this.group});

  @override
  State<MemberSelectionScreen> createState() => _MemberSelectionScreenState();
}

class _MemberSelectionScreenState extends State<MemberSelectionScreen> {
  final GroupAuthService _groupAuthService = GroupAuthService();
  List<GroupMember> _accessibleMembers = [];
  bool _isLoading = true;
  GroupMember? _selectedMember;

  @override
  void initState() {
    super.initState();
    _loadAccessibleMembers();
  }

  Future<void> _loadAccessibleMembers() async {
    try {
      final members = await _groupAuthService.getAccessibleMembers();
      setState(() {
        _accessibleMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading members: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectMember(GroupMember member) async {
    try {
      setState(() {
        _selectedMember = member;
      });

      // Set the current member in the auth service
      await _groupAuthService.setCurrentMember(member.email);

      if (mounted) {
        // Navigate to group dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GroupDashboard()),
        );
      }
    } catch (e) {
      setState(() {
        _selectedMember = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Member Role'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Card(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.group, size: 48, color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to ${widget.group.groupName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select which member role you\'re accessing as:',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Members List
                  if (_accessibleMembers.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.warning,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Active Members Found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'There are no active members in this group. Please contact your administrator.',
                              style: TextStyle(color: AppColors.secondaryText),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _accessibleMembers.map((member) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: _selectedMember?.userId == member.userId
                                ? null
                                : () => _selectMember(member),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: _getRoleColor(member.role),
                                    child: Text(
                                      member.name.isNotEmpty
                                          ? member.name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Member Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          member.roleDisplayName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _getRoleColor(member.role),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          member.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Loading or Arrow
                                  if (_selectedMember?.userId == member.userId)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.secondaryText,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _groupAuthService.signOut();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
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
}
