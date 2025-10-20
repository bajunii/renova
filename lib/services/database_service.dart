import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? '';

  // Projects Collection
  CollectionReference get projects => _firestore.collection('projects');
  CollectionReference get tasks => _firestore.collection('tasks');
  CollectionReference get users => _firestore.collection('users');

  // ==================== PROJECTS ====================

  // Create a new project
  Future<String> createProject({
    required String title,
    required String description,
    required String status,
    double? budget,
    DateTime? deadline,
  }) async {
    try {
      DocumentReference docRef = await projects.add({
        'title': title,
        'description': description,
        'status': status,
        'budget': budget ?? 0.0,
        'deadline': deadline,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'teamMembers': [userId],
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to create project: $e';
    }
  }

  // Get user's projects
  Stream<QuerySnapshot> getUserProjects() {
    return projects
        .where('teamMembers', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update project
  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await projects.doc(projectId).update(data);
    } catch (e) {
      throw 'Failed to update project: $e';
    }
  }

  // Delete project (soft delete)
  Future<void> deleteProject(String projectId) async {
    try {
      await projects.doc(projectId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      });
    } catch (e) {
      throw 'Failed to delete project: $e';
    }
  }

  // ==================== TASKS ====================

  // Create a new task
  Future<String> createTask({
    required String projectId,
    required String title,
    required String description,
    required String priority,
    String status = 'pending',
    DateTime? dueDate,
    String? assignedTo,
  }) async {
    try {
      DocumentReference docRef = await tasks.add({
        'projectId': projectId,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'dueDate': dueDate,
        'assignedTo': assignedTo ?? userId,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to create task: $e';
    }
  }

  // Get tasks for a project
  Stream<QuerySnapshot> getProjectTasks(String projectId) {
    return tasks
        .where('projectId', isEqualTo: projectId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get user's tasks
  Stream<QuerySnapshot> getUserTasks() {
    return tasks
        .where('assignedTo', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('dueDate', descending: false)
        .snapshots();
  }

  // Update task
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await tasks.doc(taskId).update(data);
    } catch (e) {
      throw 'Failed to update task: $e';
    }
  }

  // Delete task (soft delete)
  Future<void> deleteTask(String taskId) async {
    try {
      await tasks.doc(taskId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      });
    } catch (e) {
      throw 'Failed to delete task: $e';
    }
  }

  // ==================== ANALYTICS ====================

  // Get dashboard analytics
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      // Get projects count
      QuerySnapshot projectsSnapshot = await projects
          .where('teamMembers', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();

      // Get tasks count
      QuerySnapshot tasksSnapshot = await tasks
          .where('assignedTo', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      // Get completed tasks count
      QuerySnapshot completedTasksSnapshot = await tasks
          .where('assignedTo', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .where('isActive', isEqualTo: true)
          .get();

      // Calculate total budget
      double totalBudget = 0.0;
      for (QueryDocumentSnapshot doc in projectsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalBudget += (data['budget'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'projectsCount': projectsSnapshot.docs.length,
        'tasksCount': tasksSnapshot.docs.length,
        'completedTasksCount': completedTasksSnapshot.docs.length,
        'totalBudget': totalBudget,
        'completionRate': tasksSnapshot.docs.isNotEmpty
            ? (completedTasksSnapshot.docs.length /
                  tasksSnapshot.docs.length *
                  100)
            : 0.0,
      };
    } catch (e) {
      throw 'Failed to get analytics: $e';
    }
  }

  // Get monthly revenue data
  Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    try {
      // Get completed projects from last 6 months
      DateTime sixMonthsAgo = DateTime.now().subtract(
        const Duration(days: 180),
      );

      QuerySnapshot snapshot = await projects
          .where('teamMembers', arrayContains: userId)
          .where('status', isEqualTo: 'completed')
          .where('updatedAt', isGreaterThan: sixMonthsAgo)
          .get();

      Map<String, double> monthlyRevenue = {};

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['updatedAt'] as Timestamp?;
        final budget = (data['budget'] as num?)?.toDouble() ?? 0.0;

        if (timestamp != null) {
          final date = timestamp.toDate();
          final monthKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0.0) + budget;
        }
      }

      return monthlyRevenue.entries
          .map((entry) => {'month': entry.key, 'revenue': entry.value})
          .toList();
    } catch (e) {
      throw 'Failed to get monthly revenue: $e';
    }
  }

  // ==================== TEAM MANAGEMENT ====================

  // Add team member to project
  Future<void> addTeamMember(String projectId, String memberEmail) async {
    try {
      // Find user by email
      QuerySnapshot userSnapshot = await users
          .where('email', isEqualTo: memberEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw 'User not found with email: $memberEmail';
      }

      String memberId = userSnapshot.docs.first.id;

      // Add member to project
      await projects.doc(projectId).update({
        'teamMembers': FieldValue.arrayUnion([memberId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to add team member: $e';
    }
  }

  // Remove team member from project
  Future<void> removeTeamMember(String projectId, String memberId) async {
    try {
      await projects.doc(projectId).update({
        'teamMembers': FieldValue.arrayRemove([memberId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to remove team member: $e';
    }
  }

  // Get team members for project
  Future<List<Map<String, dynamic>>> getProjectTeamMembers(
    String projectId,
  ) async {
    try {
      DocumentSnapshot projectDoc = await projects.doc(projectId).get();

      if (!projectDoc.exists) {
        throw 'Project not found';
      }

      final projectData = projectDoc.data() as Map<String, dynamic>;
      final teamMemberIds = List<String>.from(projectData['teamMembers'] ?? []);

      if (teamMemberIds.isEmpty) {
        return [];
      }

      QuerySnapshot usersSnapshot = await users
          .where(FieldPath.documentId, whereIn: teamMemberIds)
          .get();

      return usersSnapshot.docs
          .map((doc) => {'id': doc.id, ...(doc.data() as Map<String, dynamic>)})
          .toList();
    } catch (e) {
      throw 'Failed to get team members: $e';
    }
  }

  // ==================== SEARCH & FILTERS ====================

  // Search projects
  Future<List<QueryDocumentSnapshot>> searchProjects(String query) async {
    try {
      QuerySnapshot snapshot = await projects
          .where('teamMembers', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] as String? ?? '').toLowerCase();
        final description = (data['description'] as String? ?? '')
            .toLowerCase();
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw 'Failed to search projects: $e';
    }
  }

  // Get projects by status
  Stream<QuerySnapshot> getProjectsByStatus(String status) {
    return projects
        .where('teamMembers', arrayContains: userId)
        .where('status', isEqualTo: status)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
