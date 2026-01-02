import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: Color(0xFFEAE6FA), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Welcome to PropGenie!

By accessing or using this app, you agree to the following terms and conditions:

1. You may not use this app for unlawful purposes.
2. Premium access grants you full proposal generation and download features.
3. We are not liable for the success of any proposals submitted using our AI.
4. No refund will be provided after purchase.
5. Your data is handled securely and is not shared with third parties.

We reserve the right to update these terms at any time.

For support, contact us at propgenie963@gmail.com

Thank you for using PropGenie!
            ''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
