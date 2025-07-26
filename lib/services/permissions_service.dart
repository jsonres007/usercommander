import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  // Request location permission
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Request storage permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Request all permissions needed for SOS functionality
  Future<Map<String, bool>> requestAllSOSPermissions() async {
    final results = <String, bool>{};
    
    results['location'] = await requestLocationPermission();
    results['camera'] = await requestCameraPermission();
    results['microphone'] = await requestMicrophonePermission();
    results['storage'] = await requestStoragePermission();
    results['notification'] = await requestNotificationPermission();
    
    return results;
  }

  // Check if all SOS permissions are granted
  Future<bool> areAllSOSPermissionsGranted() async {
    final permissions = await requestAllSOSPermissions();
    return permissions.values.every((granted) => granted);
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Open app settings for manual permission management
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
