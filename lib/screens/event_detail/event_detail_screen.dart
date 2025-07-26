import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Detail'),
      ),
      body: Center(
        child: Text('Event Detail Screen Placeholder for event ID: $eventId'),
      ),
    );
  }
}