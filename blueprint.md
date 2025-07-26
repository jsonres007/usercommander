## Project Overview:

A mobile application built with Flutter and Firebase for incident reporting and management. The application will support user authentication via SSO with Firestore, location and notification permissions, SOS functionality with media capture, real-time incident updates, nearby event display with maps, a chat feature for zone-level stats, and push notifications for predictive analysis. It will differentiate between regular users and commanders (volunteers) in how critical incident alerts are received and acted upon.

## Implemented Features:

*   Project setup with Flutter and Firebase.
*   Basic app structure and navigation (using `go_router`).
*   Material Design 3 theming with light/dark mode toggle.
*   Firebase Authentication Setup (including SSO via Google Sign-In and Firestore integration for user roles).
*   Permissions Handling (Location and Notification).
*   Initial Routing for core screens (Sign Up/Login, Home).
*   Home Page Implementation (Basic layout with SOS button, Notification and Profile icons, Hamburger menu with History, Sign out, and Settings options).

## Plan for Current Request:

1.  **Navigation and Routing:**
    *   Define remaining routes for Emergency Contacts, History, Settings, Prediction Message Screen, and Event Detail screens using `go_router`.
2.  **SOS Feature:**
    *   Implement logic for the SOS button.
    *   Add functionality for photo, voice, and video capture upon SOS activation.
    *   Implement sending captured media to a backend portal (client-side part).
    *   Implement an affirmation pop-up upon successful SOS flag.
3.  **Nearby Events Feature:**
    *   Implement displaying nearby events (will require a data source for events).
    *   Implement navigation to a zone map screen on event click.
4.  **Chat Feature:**
    *   Implement a basic chat interface.
    *   Implement logic to fetch and display zone-level statistics within the chat (will require a data source for statistics).
5.  **Push Notifications:**
    *   Set up Firebase Cloud Messaging (FCM) for push notifications.
    *   Implement handling incoming notifications, especially for critical incident alerts for commanders.
    *   Implement navigation to the Prediction Message Screen on notification click for commanders.
6.  **Commander Specific Functionality:**
    *   Implement the flash message pop-up for critical incidents for commanders.
    *   Implement navigation to Google Maps with the shortest path from the commander's current location to the incident location.
