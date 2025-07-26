import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Make sure this file is generated after configuring Firebase

import 'package:myapp/theme_provider.dart'; // Assuming you have a theme_provider.dart
import 'package:myapp/auth_gate.dart'; // We will create this file for authentication handling
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/emergency_contacts/emergency_contacts_screen.dart';
import 'package:myapp/screens/history/history_screen.dart';
import 'package:myapp/screens/settings/settings_screen.dart';
import 'package:myapp/screens/prediction_message/prediction_message_screen.dart';
import 'package:myapp/screens/event_detail/event_detail_screen.dart';
import 'package:myapp/screens/authentication/signup_screen.dart'; // Import the signup screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Your ThemeProvider
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthGate(); // Handle authentication routing here
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
     GoRoute(
      path: '/emergency_contacts',
      builder: (BuildContext context, GoRouterState state) {
        return const EmergencyContactsScreen();
      },
    ),
    GoRoute(
      path: '/history',
      builder: (BuildContext context, GoRouterState state) {
        return const HistoryScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: '/prediction_message/:id', // Example route with parameter
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id']!;
        return PredictionMessageScreen(messageId: id);
      },
    ),
    GoRoute(
      path: '/event_detail/:id', // Example route with parameter
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id']!;
        return EventDetailScreen(eventId: id);
      },
    ),
    GoRoute( // Add the signup route
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) {
        return const SignupScreen();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      routerConfig: _router,
      title: 'Incident Reporter App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.themeMode,
    );
  }
}