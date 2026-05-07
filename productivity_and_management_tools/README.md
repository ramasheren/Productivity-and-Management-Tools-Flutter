# productivity_and_management_tools

This app now uses Firebase Cloud Firestore for tasks and notes.

## Firebase setup

1. Install the FlutterFire CLI:
   `dart pub global activate flutterfire_cli`
2. From this project folder, connect the app to your Firebase project:
   `flutterfire configure`
3. Rebuild the app:
   `flutter run`

Until Firebase is configured, the app falls back to temporary in-memory storage for tasks and notes.
