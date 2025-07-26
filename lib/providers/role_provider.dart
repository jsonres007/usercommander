import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/user_service.dart';

class RoleProvider extends ChangeNotifier {
  String? _userRole;
  bool _isLoading = false;
  String? _error;
  static const String _roleKey = 'user_role';

  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the role provider by fetching the current user's role
  Future<void> initialize() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // First load cached role for immediate display
      await _loadCachedRole();
      // Then try to fetch from Firestore to update if needed
      await fetchUserRole();
    }
  }

  /// Fetch the current user's role from Firestore
  Future<void> fetchUserRole() async {
    _setLoading(true);
    _error = null;

    try {
      final String? role = await UserService.getCurrentUserRole();
      if (role != null) {
        _userRole = role;
        await _saveRoleToCache(role);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to fetch user role: $e';
      print(_error);
      
      // If we don't have a cached role and Firestore fails, try to load from cache
      if (_userRole == null) {
        await _loadCachedRole();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Update the user's role
  Future<bool> updateUserRole(String newRole) async {
    _setLoading(true);
    _error = null;

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'No authenticated user found';
        return false;
      }

      final bool success = await UserService.setUserRole(user.uid, newRole);
      if (success) {
        _userRole = newRole;
        await _saveRoleToCache(newRole);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update user role';
        return false;
      }
    } catch (e) {
      _error = 'Error updating user role: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear the user role (typically called on logout)
  void clearRole() {
    _userRole = null;
    _error = null;
    _isLoading = false;
    _clearCachedRole(); // Clear cached role as well
    notifyListeners();
  }

  /// Get the appropriate route for the current user role
  String getRouteForCurrentRole() {
    return UserService.getRouteForRole(_userRole);
  }

  /// Check if user has a specific role
  bool hasRole(String role) {
    return _userRole?.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is commander
  bool get isCommander => hasRole('commander');

  /// Check if user is regular user
  bool get isUser => hasRole('user');

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Load cached role from SharedPreferences
  Future<void> _loadCachedRole() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedRole = prefs.getString(_roleKey);
      if (cachedRole != null) {
        _userRole = cachedRole;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached role: $e');
    }
  }

  /// Save role to SharedPreferences cache
  Future<void> _saveRoleToCache(String role) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role);
    } catch (e) {
      print('Error saving role to cache: $e');
    }
  }

  /// Clear cached role from SharedPreferences
  Future<void> _clearCachedRole() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_roleKey);
    } catch (e) {
      print('Error clearing cached role: $e');
    }
  }
}
