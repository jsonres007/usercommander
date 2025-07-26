import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/authentication/login_screen.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/providers/role_provider.dart';
import 'package:myapp/screens/user/user_dashboard_screen.dart';
import 'package:myapp/screens/admin/admin_dashboard_screen.dart';
import 'package:myapp/screens/commander/commander_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData) {
          // User is logged in, initialize role provider and redirect accordingly
          return Consumer<RoleProvider>(
            builder: (context, roleProvider, child) {
              // Initialize role provider if not already done
              if (roleProvider.userRole == null && !roleProvider.isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  roleProvider.fetchUserRole();
                });
              }
              
              if (roleProvider.isLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // Get the user's role and redirect to appropriate dashboard
              final String? userRole = roleProvider.userRole;
              
              if (userRole != null) {
                // Redirect based on role
                switch (userRole.toLowerCase()) {
                  case 'user':
                    return const UserDashboardScreen();
                  case 'admin':
                    return const AdminDashboardScreen();
                  case 'commander':
                    return const CommanderDashboardScreen();
                  default:
                    // If role is not recognized, go to home for role selection
                    return const HomeScreen();
                }
              } else {
                // No role found, redirect to home screen for role selection
                return const HomeScreen();
              }
            },
          );
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}