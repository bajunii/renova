import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        body: const SafeArea(
          child: Padding(padding: EdgeInsets.all(16.0), child: HomePage()),
        ),
      ),
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  'Projects',
                  '24',
                  Icons.folder_outlined,
                  Colors.blue,
                ),
                _buildDashboardCard(
                  context,
                  'Tasks',
                  '156',
                  Icons.task_outlined,
                  Colors.green,
                ),
                _buildDashboardCard(
                  context,
                  'Revenue',
                  '\$12.5K',
                  Icons.attach_money,
                  Colors.orange,
                ),
                _buildDashboardCard(
                  context,
                  'Team',
                  '12',
                  Icons.group_outlined,
                  Colors.purple,
                ),
              ],
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
                  FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Analytics Page
// class AnalyticsPage extends StatelessWidget {
//   const AnalyticsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Analytics',
//             style: Theme.of(
//               context,
//             ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: ListView(
//               children: [
//                 _buildAnalyticsCard(
//                   context,
//                   'Monthly Revenue',
//                   '\$45,250',
//                   '+12%',
//                   Colors.green,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildAnalyticsCard(
//                   context,
//                   'Active Users',
//                   '1,234',
//                   '+5%',
//                   Colors.blue,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildAnalyticsCard(
//                   context,
//                   'Conversion Rate',
//                   '3.2%',
//                   '-0.5%',
//                   Colors.red,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalyticsCard(
//     BuildContext context,
//     String title,
//     String value,
//     String change,
//     Color changeColor,
//   ) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   value,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: changeColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     change,
//                     style: TextStyle(
//                       color: changeColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'john.doe@example.com',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(context, 'Edit Profile', Icons.edit),
                _buildProfileOption(
                  context,
                  'Notifications',
                  Icons.notifications,
                ),
                _buildProfileOption(context, 'Privacy', Icons.privacy_tip),
                _buildProfileOption(context, 'Help & Support', Icons.help),
                _buildProfileOption(context, 'About', Icons.info),
              ],
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
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
