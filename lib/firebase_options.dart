// Example (replace with your actual output)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: "your-api-key",
    appId: "your-app-id",
    messagingSenderId: "your-sender-id",
    projectId: "hectoclash",
    authDomain: "hectoclash.firebaseapp.com",
    databaseURL: "https://hectoclash-default-rtdb.firebaseio.com",
    storageBucket: "hectoclash.appspot.com",
  );
}