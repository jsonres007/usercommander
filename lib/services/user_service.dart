import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's role from Firestore
  static Future<String?> getCurrentUserRole() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  /// Store or update user role in Firestore
  static Future<bool> setUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'role': role,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error setting user role: $e');
      return false;
    }
  }

  /// Get user data including role
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Get the appropriate route based on user role
  static String getRouteForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'user':
        return '/user_dashboard';
      case 'admin':
        return '/admin_dashboard';
      case 'commander':
        return '/commander_dashboard';
      default:
        return '/home'; // Default fallback to role selection
    }
  }

  /// Check if user exists in Firestore
  static Future<bool> userExists(String uid) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }
}
