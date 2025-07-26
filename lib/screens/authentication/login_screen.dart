import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/providers/role_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FirebaseFirestore _firestore;
  
  String _selectedRole = 'User'; // Default role
  final List<String> _roles = ['User', 'Admin', 'Commander'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
  }

  void _initializeFirestore() {
    try {
      _firestore = FirebaseFirestore.instance;
      // Enable offline persistence for better reliability
      _firestore.enablePersistence();
    } catch (e) {
      print('Firestore initialization error: $e');
      _firestore = FirebaseFirestore.instance;
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // First authenticate the user
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        
        // Store user role in Firestore with retry logic
        await _storeUserDataWithRetry(userCredential.user!.uid);
        
        // Update role provider with the selected role
        if (mounted) {
          final roleProvider = Provider.of<RoleProvider>(context, listen: false);
          await roleProvider.updateUserRole(_selectedRole);
          
          // Navigate based on role
          final String route = UserService.getRouteForRole(_selectedRole);
          context.go(route);
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided for that user.';
        } else {
          message = 'Login failed. Please try again.';
        }
        _showErrorMessage(message);
      } catch (e) {
        print('An unexpected error occurred: $e');
        _showErrorMessage('An unexpected error occurred. Please try again.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _storeUserDataWithRetry(String uid, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _firestore.collection('users').doc(uid).set({
          'email': _emailController.text,
          'role': _selectedRole,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return; // Success, exit the retry loop
      } catch (e) {
        print('Firestore write attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          // If all retries failed, still allow login but show warning
          _showErrorMessage('Login successful, but profile update failed. Please check your connection.');
          return;
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt));
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
               // Placeholder for Logo or App Title
              Text(
                'Incident Reporter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48.0),
              const Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
              const SizedBox(height: 32.0),
              // Role Selection
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    hint: const Text('Select Role'),
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // TODO: Add more robust email validation if needed
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                   // TODO: Add more robust password validation if needed
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
               const SizedBox(height: 16.0),
               TextButton( // Navigate to Sign Up screen
                 onPressed: () {
                   if (mounted) {
                     context.go('/signup'); // Navigate to the signup screen
                   }
                 },
                 child: const Text("Don't have an account? Sign Up"),
               ),
               const SizedBox(height: 8.0),

              ],
            ),
          ),
        ),
      ),
    );
  } 
}
