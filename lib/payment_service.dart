import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  late Razorpay _razorpay;

  Function(String paymentId)? onSuccess;
  Function(String error)? onFailure;

  void init(
    Function(String paymentId) successCallback,
    Function(String error) failureCallback,
  ) {
    _razorpay = Razorpay();
    onSuccess = successCallback;
    onFailure = failureCallback;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String email,
    required String contact,
  }) {
    var options = {
      'key': 'rzp_test_uel7f5tRCudSvT', // 🔑 Replace with live key later
      'amount': 6000, // ₹60 in paise
      'name': 'PropGenie',
      'description': '6-month premium access',
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error in opening Razorpay: $e");
    }
  }

  /// 🔓 Handles successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email) // or user.uid if you prefer
            .set({
              'isPaidUser': true,
              'paymentId': response.paymentId,
              'paidTill': DateTime.now().add(const Duration(days: 180)),
            }, SetOptions(merge: true));

        debugPrint("✅ Payment stored in Firestore & premium unlocked.");
      } catch (e) {
        debugPrint("⚠️ Firestore update failed: $e");
      }
    }

    if (onSuccess != null) {
      onSuccess!(response.paymentId ?? "NoPaymentID");
    }
  }

  /// ❌ Handles payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    final errorMsg =
        "Code: ${response.code}, Message: ${response.message ?? 'Unknown Error'}";
    debugPrint(errorMsg);
    if (onFailure != null) {
      onFailure!(errorMsg);
    }
  }

  /// 👜 Handles external wallet (e.g., Paytm)
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet selected: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }
}
