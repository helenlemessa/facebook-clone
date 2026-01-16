// File generated using: flutterfire configure
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// To generate this file, run:
// flutter pub add firebase_core
// dart pub global activate flutterfire_cli
// flutterfire configure

Future<void> initializeFirebase(dynamic DefaultFirebaseOptions) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}