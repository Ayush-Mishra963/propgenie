import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help & Support"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Need Help?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              "For any issues or questions, feel free to email us at:",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            SelectableText(
              "propgenie963@gmail.com", 
              style: TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
            SizedBox(height: 20),
            Text(
              "We usually respond within 24 hours.",
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Text(
              "Make sure to include your registered email or user ID for faster assistance (Also add screenshot if any error is faced.).",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
