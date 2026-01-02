import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Add Firestore
import 'proposal_screen.dart';
import 'forgot_password_screen.dart';

bool _obscurePassword = true;

const Color kPrimaryPurple = Color(0xFFEAE6FA);
const Color kAccentCircle = Color(0xFFBDADEA);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';
  bool _isLoading = false;
  bool _isPressed = false;

  // ✅ Save user to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Set data only if document doesn't exist
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      await docRef.set({
        'email': user.email,
        'premium': false,
        'postSignupAttempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _signUpWithEmail() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ Save to Firestore
      await _saveUserToFirestore(cred.user!);

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _error = 'Email already in use. Please log in.';
        } else {
          _error = e.message ?? 'Signup failed.';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _error = 'User not found. Please sign up first.';
        } else if (e.code == 'wrong-password') {
          _error = 'Wrong password.';
        } else {
          _error = e.message ?? 'Login failed.';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);

      // ✅ Save to Firestore
      await _saveUserToFirestore(cred.user!);

    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Google sign-in failed.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user != null) return const ProposalScreen();

        return Scaffold(
          body: Stack(
            children: [
              Container(color: const Color(0xFFEAE6FA)),
              Positioned(
                top: -60,
                left: -40,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: const Color(0xFFBDADEA).withOpacity(0.2),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -60,
                child: CircleAvatar(
                  radius: 120,
                  backgroundColor: const Color(0xFFBDADEA).withOpacity(0.25),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Image.asset('assets/logo.png', height: 100),
                      const SizedBox(height: 30),
                      const Text("Login / Signup", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),

                      TextField(controller: _emailController, decoration: _inputDecoration("Email")),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration("Password").copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                          },
                          child: const Text("Forgot Password?"),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              children: [
                                _animatedButton(
                                  icon: Icons.person_add,
                                  label: "Signup with Email",
                                  onPressed: _signUpWithEmail,
                                ),
                                const SizedBox(height: 10),
                                _animatedButton(
                                  icon: Icons.login,
                                  label: "Login with Email",
                                  onPressed: _signInWithEmail,
                                ),
                                const SizedBox(height: 10),
                                _animatedButton(
                                  icon: Icons.g_mobiledata,
                                  label: "Sign in with Google",
                                  onPressed: _signInWithGoogle,
                                ),
                              ],
                            ),

                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(_error, style: const TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _animatedButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        onPressed: () async {
          setState(() => _isPressed = true);
          onPressed();
          setState(() => _isPressed = false);
        },
        style: _buttonStyle(),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(45),
      backgroundColor: const Color(0xFF7C4DFF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
