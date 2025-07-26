import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/role_provider.dart';

class CommanderDashboardScreen extends StatelessWidget {
  const CommanderDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commander Dashboard'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show critical notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Critical Notifications - Coming Soon')),
              );
            },
          ),
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
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Commander Control Center',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('As a Commander, you have access to:'),
                    const SizedBox(height: 8),
                    const Text('• Real-time critical incident alerts'),
                    const Text('• Flash message notifications'),
                    const Text('• GPS navigation to incident locations'),
                    const Text('• Emergency response coordination'),
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
                    'Active Incidents',
                    Icons.warning,
                    Colors.red,
                    () {
                      // TODO: Navigate to active incidents
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Active Incidents - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Emergency Map',
                    Icons.map,
                    Colors.blue,
                    () {
                      // TODO: Navigate to emergency map
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Emergency Map - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Response Teams',
                    Icons.group,
                    Colors.green,
                    () {
                      // TODO: Navigate to response teams
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Response Teams - Coming Soon')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Communication',
                    Icons.chat,
                    Colors.orange,
                    () {
                      // TODO: Navigate to communication center
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Communication Center - Coming Soon')),
                      );
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
          // TODO: Implement emergency broadcast
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency Broadcast - Coming Soon'),
              backgroundColor: Colors.red,
            ),
          );
        },
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign),
        label: const Text('Emergency Broadcast'),
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
