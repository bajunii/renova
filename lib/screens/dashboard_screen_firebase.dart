import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class DashboardScreenFirebase extends StatefulWidget {
  const DashboardScreenFirebase({super.key});

  @override
  State<DashboardScreenFirebase> createState() =>
      _DashboardScreenFirebaseState();
}

class _DashboardScreenFirebaseState extends State<DashboardScreenFirebase> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();

  final List<Widget> _pages = [
    const HomePageFirebase(),
    const AnalyticsPageFirebase(),
    const ProfilePageFirebase(),
    const SettingsPageFirebase(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Analytics',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renova Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Handle notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature')),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(_authService.currentUser?.displayName ?? 'Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}

// Home Page with Firebase Data
class HomePageFirebase extends StatelessWidget {
  const HomePageFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your projects today.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: databaseService.getDashboardAnalytics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Trigger rebuild
                            (context as Element).markNeedsBuild();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final analytics = snapshot.data ?? {};
                return GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      'Projects',
                      analytics['projectsCount']?.toString() ?? '0',
                      Icons.folder_outlined,
                      Colors.blue,
                    ),
                    _buildDashboardCard(
                      context,
                      'Tasks',
                      analytics['tasksCount']?.toString() ?? '0',
                      Icons.task_outlined,
                      Colors.green,
                    ),
                    _buildDashboardCard(
                      context,
                      'Budget',
                      '\$${analytics['totalBudget']?.toStringAsFixed(1) ?? '0.0'}K',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                    _buildDashboardCard(
                      context,
                      'Completion',
                      '${analytics['completionRate']?.toStringAsFixed(1) ?? '0.0'}%',
                      Icons.check_circle_outlined,
                      Colors.purple,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Analytics Page with Firebase Data
class AnalyticsPageFirebase extends StatelessWidget {
  const AnalyticsPageFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: databaseService.getMonthlyRevenue(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final revenueData = snapshot.data ?? [];
                double totalRevenue = revenueData.fold(
                  0.0,
                  (sum, item) => sum + (item['revenue'] as double),
                );

                return ListView(
                  children: [
                    _buildAnalyticsCard(
                      context,
                      'Total Revenue',
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      '+${revenueData.length > 1 ? ((revenueData.last['revenue'] / revenueData.first['revenue'] - 1) * 100).toStringAsFixed(1) : '0'}%',
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      context,
                      'Active Projects',
                      revenueData.length.toString(),
                      '+2%',
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      context,
                      'Monthly Revenue Trend',
                      revenueData.isNotEmpty
                          ? '\$${revenueData.last['revenue'].toStringAsFixed(2)}'
                          : '\$0.00',
                      revenueData.length > 1 ? '+5%' : '0%',
                      Colors.orange,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    String change,
    Color changeColor,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Page with Firebase Data
class ProfilePageFirebase extends StatelessWidget {
  const ProfilePageFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue,
            child: Text(
              user?.displayName?.substring(0, 1).toUpperCase() ??
                  user?.email?.substring(0, 1).toUpperCase() ??
                  'U',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'User',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'user@example.com',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: authService.getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data;

                return ListView(
                  children: [
                    _buildProfileOption(context, 'Edit Profile', Icons.edit),
                    _buildProfileOption(
                      context,
                      'Notifications',
                      Icons.notifications,
                    ),
                    _buildProfileOption(context, 'Privacy', Icons.privacy_tip),
                    _buildProfileOption(context, 'Help & Support', Icons.help),
                    if (userData?['createdAt'] != null)
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Member Since'),
                        subtitle: Text(
                          '${userData!['createdAt'].toDate().year}',
                        ),
                      ),
                    _buildProfileOption(context, 'About', Icons.info),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title feature')));
      },
    );
  }
}

// Settings Page
class SettingsPageFirebase extends StatefulWidget {
  const SettingsPageFirebase({super.key});

  @override
  State<SettingsPageFirebase> createState() => _SettingsPageFirebaseState();
}

class _SettingsPageFirebaseState extends State<SettingsPageFirebase> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSettingsSection('Preferences', [
                  _buildSwitchTile(
                    'Notifications',
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Dark Mode',
                    _darkModeEnabled,
                    (value) => setState(() => _darkModeEnabled = value),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSettingsSection('Security', [
                  _buildSwitchTile(
                    'Biometric Authentication',
                    _biometricEnabled,
                    (value) => setState(() => _biometricEnabled = value),
                  ),
                  _buildSettingsTile('Change Password', Icons.lock),
                  _buildSettingsTile(
                    'Two-Factor Authentication',
                    Icons.security,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSettingsSection('App', [
                  _buildSettingsTile('Language', Icons.language),
                  _buildSettingsTile('Storage', Icons.storage),
                  _buildSettingsTile('Clear Cache', Icons.clear),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Card(elevation: 1, child: Column(children: children)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSettingsTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title feature')));
      },
    );
  }
}
