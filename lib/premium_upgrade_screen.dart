import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_service.dart';
import 'terms_screen.dart'; 

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  final paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    paymentService.init(
      _handlePaymentSuccess,
      _handlePaymentFailure,
    );
  }

  Future<void> _handlePaymentSuccess(String paymentId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'premium': true},
        SetOptions(merge: true),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Payment Success: $paymentId")),
      );

      Navigator.pop(context); // Return to previous screen
    }
  }

  void _handlePaymentFailure(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Payment Failed: $error")),
    );
  }

  @override
  void dispose() {
    paymentService.dispose();
    super.dispose();
  }

  void _payNow() {
    paymentService.openCheckout(
      email: "testuser@example.com",
      contact: "9999999999",
    );
  }

  void _openTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade to Premium")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Get unlimited proposal generations for 6 months.\nOnly ₹60!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              "This is Test Version of the PropGenie. In test version no amount will be deducted from your account",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 188, 36, 25)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _payNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Pay ₹60 and Upgrade"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _openTermsAndConditions,
              child: const Text(
                "View Terms & Conditions",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
