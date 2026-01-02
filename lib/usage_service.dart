import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> isAllowedToGenerate() async {
    try {
      final user = _auth.currentUser;

      // ✅ Developer bypass (remove or control with email in production)
      const bool isDeveloper = false;
      if (isDeveloper) return true;

      if (user == null) return false;

      final docRef = _firestore.collection("users").doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          "postSignupAttempts": 1,
          "premium": false,
        });
        return true;
      }

      final data = doc.data() ?? {};
      final int attempts = data["postSignupAttempts"] is int
          ? data["postSignupAttempts"]
          : 0;
      final bool isPremium = data["premium"] == true;

      if (isPremium) return true;

      if (attempts >= 5) return false;

      await docRef.update({"postSignupAttempts": attempts + 1});
      return true;
    } catch (e) {
      print("⚠️ UsageService error: $e");
      return false; // deny access if error occurs
    }
  }
} 