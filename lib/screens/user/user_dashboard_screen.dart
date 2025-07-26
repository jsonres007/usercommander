import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/role_provider.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
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
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          alignment: Alignment.center,
                          child: Icon(Icons.person, color: Colors.blue.shade700),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'User Control Panel',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('As a User, you can:'),
                    const SizedBox(height: 8),
                    const Text('• Report incidents and emergencies'),
                    const Text('• Send SOS alerts with location'),
                    const Text('• Capture and share media evidence'),
                    const Text('• Access emergency contacts'),
                    const Text('• View incident history'),
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
                    'SOS Alert',
                    Icons.emergency,
                    Colors.red,
                    () {
                      // TODO: Navigate to SOS functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SOS Alert - Coming Soon'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Report Incident',
                    Icons.report_problem,
                    Colors.orange,
                    () {
                      // TODO: Navigate to incident reporting
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report Incident - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Emergency Contacts',
                    Icons.contacts,
                    Colors.green,
                    () {
                      context.go('/emergency_contacts');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'History',
                    Icons.history,
                    Colors.blue,
                    () {
                      context.go('/history');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Camera',
                    Icons.camera_alt,
                    Colors.purple,
                    () {
                      // TODO: Navigate to camera functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Camera - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Settings',
                    Icons.settings,
                    Colors.grey,
                    () {
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement quick SOS
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quick SOS - Coming Soon'),
              backgroundColor: Colors.red,
            ),
          );
        },
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: Container(
          height: 100,
          width: 100,
          alignment: Alignment.center,
          child: const Icon(Icons.emergency),
        ),
        label: const Text('Quick SOS'),
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
    return Container(
      // elevation: 4,
      constraints: BoxConstraints(
    maxWidth: 100,
    maxHeight: 100,
  ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
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
