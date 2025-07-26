import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'permissions_service.dart';

class SOSService {
  static final SOSService _instance = SOSService._internal();
  factory SOSService() => _instance;
  SOSService._internal();

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final PermissionsService _permissionsService = PermissionsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Trigger SOS with automatic media capture
  Future<Map<String, dynamic>> triggerSOS(BuildContext context) async {
    try {
      // Check permissions first
      final permissionsGranted = await _permissionsService.areAllSOSPermissionsGranted();
      if (!permissionsGranted) {
        throw Exception('Required permissions not granted');
      }

      // Get current location
      final position = await _permissionsService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Activating SOS...'),
              Text('Capturing evidence...'),
            ],
          ),
        ),
      );

      // Capture media automatically
      final mediaFiles = await _captureAllMedia();

      // Create SOS incident record
      final sosData = await _createSOSIncident(position, mediaFiles);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success confirmation
      if (context.mounted) {
        _showSOSConfirmation(context, sosData['incidentId']);
      }

      return sosData;
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
      
      rethrow;
    }
  }

  // Capture all media types automatically
  Future<Map<String, String?>> _captureAllMedia() async {
    final mediaFiles = <String, String?>{};

    try {
      // Capture photo
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      mediaFiles['photo'] = photo?.path;

      // Start audio recording
      final audioPath = await _startAudioRecording();
      
      // Record for 10 seconds
      await Future.delayed(const Duration(seconds: 10));
      
      // Stop audio recording
      final audioFile = await _stopAudioRecording();
      mediaFiles['audio'] = audioFile;

      // Capture video (5 seconds)
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 5),
      );
      mediaFiles['video'] = video?.path;

    } catch (e) {
      print('Error capturing media: $e');
    }

    return mediaFiles;
  }

  // Start audio recording
  Future<String?> _startAudioRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioPath = '${directory.path}/sos_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _recorder.start(const RecordConfig(), path: audioPath);
      return audioPath;
    } catch (e) {
      print('Error starting audio recording: $e');
      return null;
    }
  }

  // Stop audio recording
  Future<String?> _stopAudioRecording() async {
    try {
      return await _recorder.stop();
    } catch (e) {
      print('Error stopping audio recording: $e');
      return null;
    }
  }

  // Create SOS incident in Firestore
  Future<Map<String, dynamic>> _createSOSIncident(
    Position position,
    Map<String, String?> mediaFiles,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final incidentId = _firestore.collection('sos_incidents').doc().id;
    final timestamp = FieldValue.serverTimestamp();

    // Upload media files to Firebase Storage
    final mediaUrls = await _uploadMediaFiles(incidentId, mediaFiles);

    final incidentData = {
      'incidentId': incidentId,
      'userId': user.uid,
      'userEmail': user.email,
      'timestamp': timestamp,
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      },
      'status': 'active',
      'mediaFiles': mediaUrls,
      'responseTeams': [],
      'priority': 'high',
    };

    await _firestore.collection('sos_incidents').doc(incidentId).set(incidentData);

    return incidentData;
  }

  // Upload media files to Firebase Storage
  Future<Map<String, String>> _uploadMediaFiles(
    String incidentId,
    Map<String, String?> mediaFiles,
  ) async {
    final mediaUrls = <String, String>{};

    for (final entry in mediaFiles.entries) {
      if (entry.value != null) {
        try {
          final file = File(entry.value!);
          if (await file.exists()) {
            final ref = _storage.ref().child('sos_incidents/$incidentId/${entry.key}');
            final uploadTask = await ref.putFile(file);
            final downloadUrl = await uploadTask.ref.getDownloadURL();
            mediaUrls[entry.key] = downloadUrl;
          }
        } catch (e) {
          print('Error uploading ${entry.key}: $e');
        }
      }
    }

    return mediaUrls;
  }

  // Show SOS confirmation dialog
  void _showSOSConfirmation(BuildContext context, String incidentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('SOS Activated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your SOS signal has been sent successfully!'),
            const SizedBox(height: 16),
            Text('Incident ID: $incidentId'),
            const SizedBox(height: 8),
            const Text('Emergency services have been notified.'),
            const Text('Help is on the way.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error dialog
  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Text('SOS Error'),
          ],
        ),
        content: Text('Failed to activate SOS: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Manual photo capture
  Future<String?> capturePhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return photo?.path;
    } catch (e) {
      print('Error capturing photo: $e');
      return null;
    }
  }

  // Manual video capture
  Future<String?> captureVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      return video?.path;
    } catch (e) {
      print('Error capturing video: $e');
      return null;
    }
  }
}
