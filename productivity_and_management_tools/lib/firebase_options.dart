import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured yet. Run "flutterfire configure" to '
      'generate lib/firebase_options.dart for your project.',
    );
  }
}
