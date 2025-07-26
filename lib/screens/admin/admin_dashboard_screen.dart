import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/role_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Clear role provider state
              final roleProvider = Provider.of<RoleProvider>(context, listen: false);
              roleProvider.clearRole();
              
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Overview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const Text('Welcome to the Admin Dashboard. Here you can:'),
                    const SizedBox(height: 8),
                    const Text('• Manage user accounts and roles'),
                    const Text('• View incident reports and analytics'),
                    const Text('• Configure system settings'),
                    const Text('• Monitor commander activities'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    'User Management',
                    Icons.people,
                    Colors.blue,
                    () {
                      // TODO: Navigate to user management
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User Management - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Incident Reports',
                    Icons.report,
                    Colors.orange,
                    () {
                      // TODO: Navigate to incident reports
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incident Reports - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Analytics',
                    Icons.analytics,
                    Colors.green,
                    () {
                      // TODO: Navigate to analytics
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Analytics - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'System Settings',
                    Icons.settings,
                    Colors.purple,
                    () {
                      // TODO: Navigate to system settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('System Settings - Coming Soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 100,
                  maxWidth: 100,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
